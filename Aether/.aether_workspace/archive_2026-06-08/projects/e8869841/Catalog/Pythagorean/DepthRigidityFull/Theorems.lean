/-
# Depth Rigidity for Full EML with Inversions — Theorems

This file proves the main depth rigidity theorems for the full EML language
over positive reals, with inversion available as an operation.

## Main Results

1. **`growthRank_eq_depth`**: Growth rank equals depth for expression trees.
2. **`growthRank_inv`**: Inversion preserves growth rank.
3. **`eval_pos_of_posConsts`**: Expressions with positive constants evaluate
   to positive values on positive inputs.
4. **`hasReciprocalEnvelope_of_posConsts`**: Every positive-constant expression
   of depth `d` has a reciprocal envelope at level `d`.
5. **`iterExp_exceeds_tower_majorant`**: `iterExp (d+1)` eventually exceeds
   any poly-tower majorant at level `d`.
6. **`iterExp_depth_rigidity_full`**: The flagship theorem — any expression
   computing `iterExp n` on positive reals must have depth ≥ n.

## Proof Architecture

We use **Strategy A: Asymptotic envelope induction on expression structure**.

The key invariant is `HasReciprocalEnvelope d (e.eval)`, which bounds both
`e.eval x` and `(e.eval x)⁻¹` by `iterExp d (C · x^N)` for large `x`.

- **Base**: variables and positive constants satisfy the envelope at level 0.
- **Mul**: products preserve the envelope level via tower absorption.
- **Inv**: inversion trivially preserves the envelope by swapping bounds.
- **Exp**: exponentiation increases the envelope level by exactly 1.

The separation step uses the tower domination theorem from the catalog:
`iterExp (d+1) x` eventually exceeds `iterExp d (C · x^N)` for any `C, N`.
-/
import Pythagorean.DepthRigidityFull.Defs

noncomputable section

open Real Filter PosExpr

/-! ## Basic Properties of iterExp -/

theorem iterExp_pos_of_pos (n : ℕ) {x : ℝ} (hx : 0 < x) : 0 < iterExp n x := by
  induction n with
  | zero => exact hx
  | succ _ _ => exact Real.exp_pos _

theorem iterExp_pos_of_succ (n : ℕ) (x : ℝ) : 0 < iterExp (n + 1) x :=
  Real.exp_pos _

theorem iterExp_nonneg (n : ℕ) (x : ℝ) (hn : 1 ≤ n) : 0 ≤ iterExp n x := by
  cases n with
  | zero => omega
  | succ n => exact le_of_lt (Real.exp_pos _)

theorem iterExp_strictMono (n : ℕ) : StrictMono (iterExp n) := by
  induction n with
  | zero => exact strictMono_id
  | succ n ih => exact Real.exp_strictMono.comp ih

theorem iterExp_mono (n : ℕ) : Monotone (iterExp n) :=
  (iterExp_strictMono n).monotone

theorem iterExp_compose (k m : ℕ) (x : ℝ) :
    iterExp k (iterExp m x) = iterExp (k + m) x := by
  induction k with
  | zero => simp [iterExp]
  | succ k ih => simp [iterExp_succ, ih, Nat.succ_add]

theorem iterExp_ge_self (n : ℕ) {x : ℝ} (hx : 0 ≤ x) : x ≤ iterExp n x := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc x ≤ iterExp n x := ih
    _ ≤ Real.exp (iterExp n x) := by linarith [Real.add_one_le_exp (iterExp n x)]

theorem iterExp_nonneg_of_nonneg (n : ℕ) {x : ℝ} (hx : 0 ≤ x) : 0 ≤ iterExp n x := by
  cases n with
  | zero => exact hx
  | succ _ => exact le_of_lt (Real.exp_pos _)

theorem one_le_iterExp_of_nonneg (n : ℕ) {x : ℝ} (hx : 0 ≤ x) (hn : 1 ≤ n) :
    1 ≤ iterExp n x := by
  cases n with
  | zero => omega
  | succ n =>
    simp only [iterExp_succ]
    exact Real.one_le_exp (iterExp_nonneg_of_nonneg n hx)

/-! ## Growth Rank Equals Depth for Expression Trees -/

/-- Growth rank equals depth for expression trees. This is a structural identity
    reflecting that in the tree representation (as opposed to DAGs), there is no
    subexpression sharing to create a gap between syntactic depth and semantic
    growth potential. -/
theorem growthRank_eq_depth (e : PosExpr) : e.growthRank = e.depth := by
  induction e with
  | var => rfl
  | const _ => rfl
  | mul a b iha ihb => simp [PosExpr.growthRank, PosExpr.depth, iha, ihb]
  | inv a ih => simp [PosExpr.growthRank, PosExpr.depth, ih]
  | exp a ih => simp [PosExpr.growthRank, PosExpr.depth, ih]

/-- Growth rank is preserved by inversion. This is the key structural lemma
    showing that division cannot manufacture exponential tower levels. -/
theorem growthRank_inv (e : PosExpr) :
    (PosExpr.inv e).growthRank = e.growthRank := by
  simp [PosExpr.growthRank]

/-- Depth is preserved by inversion. Inversion is a "free" operation
    in terms of exponential nesting complexity. -/
theorem depth_inv (e : PosExpr) :
    (PosExpr.inv e).depth = e.depth := by
  simp [PosExpr.depth]

/-- Growth rank is bounded by depth. (In fact they are equal for trees,
    but this formulation is more useful for the depth rigidity argument.) -/
theorem growthRank_le_depth (e : PosExpr) : e.growthRank ≤ e.depth := by
  rw [growthRank_eq_depth]

/-- LogTameIndex equals growthRank (and depth) for all expressions. -/
theorem logTameIndex_eq_growthRank (e : PosExpr) :
    e.logTameIndex = e.growthRank := by
  induction e with
  | var => rfl
  | const _ => rfl
  | mul a b iha ihb => simp [PosExpr.logTameIndex, PosExpr.growthRank, iha, ihb]
  | inv a ih => simp [PosExpr.logTameIndex, PosExpr.growthRank, ih]
  | exp a ih => simp [PosExpr.logTameIndex, PosExpr.growthRank, ih]

/-! ## Positivity of Evaluation -/

/-- Expressions with all-positive constants evaluate to strictly positive values
    on positive inputs. This is the semantic foundation of the positive-real fragment:
    positivity is preserved by all operations (mul, inv, exp). -/
theorem eval_pos_of_posConsts (e : PosExpr) (hpc : e.posConsts)
    {x : ℝ} (hx : 0 < x) : 0 < e.eval x := by
  induction e with
  | var => exact hx
  | const c => exact hpc
  | mul a b iha ihb =>
    simp [PosExpr.eval]
    exact mul_pos (iha hpc.1) (ihb hpc.2)
  | inv a ih =>
    simp only [PosExpr.eval]
    exact inv_pos (a := a.eval x) |>.mpr (ih hpc)
  | exp a _ =>
    simp [PosExpr.eval]
    exact Real.exp_pos _

/-! ## Canonical iterExp Properties -/

/-- The canonical expression for `iterExp n` computes it correctly. -/
theorem canonIterExp_eval (n : ℕ) (x : ℝ) :
    (canonIterExp n).eval x = iterExp n x := by
  induction n with
  | zero => simp [canonIterExp, PosExpr.eval, iterExp]
  | succ n ih => simp [canonIterExp, PosExpr.eval, iterExp, ih]

/-- The canonical expression for `iterExp n` has depth exactly `n`. -/
theorem canonIterExp_depth (n : ℕ) :
    (canonIterExp n).depth = n := by
  induction n with
  | zero => simp [canonIterExp, PosExpr.depth]
  | succ n ih => simp [canonIterExp, PosExpr.depth, ih]; omega

/-- The canonical expression has all-positive constants (vacuously — no constants). -/
theorem canonIterExp_posConsts (n : ℕ) :
    (canonIterExp n).posConsts := by
  induction n with
  | zero => simp [canonIterExp, PosExpr.posConsts]
  | succ n ih => simp [canonIterExp, PosExpr.posConsts, ih]

/-- The canonical expression is inverse-free. -/
theorem canonIterExp_invFree (n : ℕ) :
    (canonIterExp n).invFree := by
  induction n with
  | zero => simp [canonIterExp, PosExpr.invFree]
  | succ n ih => simp [canonIterExp, PosExpr.invFree, ih]

/-! ## Tower Domination -/

/-
Polynomials are eventually dominated by exp.
-/
theorem poly_lt_exp (C : ℝ) (N : ℕ) :
    ∃ X₀ : ℝ, 0 < X₀ ∧ ∀ x : ℝ, x ≥ X₀ → C * x ^ N < Real.exp x := by
  -- Use the fact that exp(x) / x^N tends to infinity as x approaches infinity.
  have h_exp_div_pow_inf : Filter.Tendsto (fun x : ℝ => Real.exp x / x ^ N) Filter.atTop Filter.atTop := by
    exact Real.tendsto_exp_div_pow_atTop N
  generalize_proofs at *; (
  exact Filter.eventually_atTop.mp ( h_exp_div_pow_inf.eventually_gt_atTop ( C ) ) |> fun ⟨ X₀, hX₀ ⟩ ↦ ⟨ Max.max X₀ 1, by positivity, fun x hx ↦ by have := hX₀ x ( le_trans ( le_max_left _ _ ) hx ) ; rw [ lt_div_iff₀ ( pow_pos ( by linarith [ le_max_right X₀ 1 ] ) _ ) ] at this; linarith ⟩ ;)

/-
A polynomial tower majorant at level `d` is eventually dominated by
    `iterExp (d+1) x`. This is the key separation lemma.
-/
theorem iterExp_poly_lt_iterExp_succ (d : ℕ) (C : ℝ) (N : ℕ) :
    ∃ X₀ : ℝ, 0 < X₀ ∧ ∀ x : ℝ, x ≥ X₀ →
      iterExp d (C * x ^ N) < iterExp (d + 1) x := by
  induction' d with d ih generalizing C N;
  · obtain ⟨ X₀, hX₀ ⟩ := poly_lt_exp C N;
    exact ⟨ X₀, hX₀.1, fun x hx => hX₀.2 x hx ⟩;
  · obtain ⟨ X₀, hX₀₁, hX₀₂ ⟩ := ih C N;
    exact ⟨ X₀, hX₀₁, fun x hx => by simpa [ iterExp_succ ] using Real.exp_lt_exp.mpr ( hX₀₂ x hx ) ⟩

/-! ## Reciprocal Envelope: Structural Lemmas -/

/-
Variables have a reciprocal envelope at level 0.
-/
theorem hasReciprocalEnvelope_var :
    HasReciprocalEnvelope 0 (fun x => x) := by
  use 1, by norm_num, 1, 1, by norm_num;
  simp +zetaDelta at *;
  exact fun x hx => by rw [ inv_eq_one_div, div_le_iff₀ ] <;> nlinarith;

/-
Positive constants have a reciprocal envelope at level 0.
-/
theorem hasReciprocalEnvelope_const (c : ℝ) (hc : 0 < c) :
    HasReciprocalEnvelope 0 (fun _ => c) := by
  refine' ⟨ 1 + Max.max c ( c⁻¹ ), by positivity, 0, 1, by positivity, fun x hx => _ ⟩ ; norm_num;
  constructor <;> linarith [ le_max_left c c⁻¹, le_max_right c c⁻¹ ]

/-
**Inversion preserves reciprocal envelopes.**
    This is the critical structural lemma: if `f` has a reciprocal envelope
    at level `d`, then so does `1/f`. The proof is trivial because the
    reciprocal envelope is defined symmetrically — it bounds both `f` and `1/f`.
    Inversion simply swaps these two bounds.

    This is the formal heart of why division cannot collapse the depth hierarchy.
-/
theorem HasReciprocalEnvelope.inv {d : ℕ} {f : ℝ → ℝ}
    (hf : HasReciprocalEnvelope d f) :
    HasReciprocalEnvelope d (fun x => (f x)⁻¹) := by
  obtain ⟨ C, hC_pos, N, X₀, hX₀_pos, h ⟩ := hf;
  use C, hC_pos, N, X₀, hX₀_pos;
  intro x hx; specialize h x hx; aesop;

/-
Monotonicity of HasReciprocalEnvelope in the level parameter.
-/
theorem HasReciprocalEnvelope.mono {d₁ d₂ : ℕ} {f : ℝ → ℝ}
    (hf : HasReciprocalEnvelope d₁ f) (hle : d₁ ≤ d₂) :
    HasReciprocalEnvelope d₂ f := by
  obtain ⟨ C, hC, N, X₀, hX₀, h ⟩ := hf
  use C, hC, N, X₀, hX₀
  intro x hx
  have h_bound : iterExp d₁ (C * x ^ N) ≤ iterExp d₂ (C * x ^ N) := by
    exact Nat.le_induction ( by norm_num ) ( fun k hk ih => by simpa only [ iterExp_succ ] using le_trans ih ( by linarith [ Real.add_one_le_exp ( iterExp k ( C * x ^ N ) ) ] ) ) d₂ hle
  generalize_proofs at *;
  grind

/-
Tower sum absorption for d ≥ 1: iterExp d u + iterExp d v ≤ iterExp d (max u v + 1)
    when u, v ≥ 0.
-/
theorem iterExp_sum_le_iterExp_max_succ {d : ℕ} (hd : 1 ≤ d) {u v : ℝ}
    (hu : 0 ≤ u) (hv : 0 ≤ v) :
    iterExp d u + iterExp d v ≤ iterExp d (max u v + 1) := by
  induction' hd with d hd ih;
  · simp +zetaDelta at *;
    cases max_cases u v <;> simp +decide [ *, Real.exp_add ];
    · nlinarith [ Real.add_one_le_exp 1, Real.exp_pos u, Real.exp_le_exp.2 ( by linarith : v ≤ u ) ];
    · nlinarith [ Real.add_one_le_exp 1, Real.exp_pos u, Real.exp_pos v, Real.exp_le_exp.2 ( by linarith : u ≤ v ) ];
  · -- By the properties of the exponential function and the induction hypothesis, we have:
    have h_exp : Real.exp (iterExp d u) + Real.exp (iterExp d v) ≤ 2 * Real.exp (max (iterExp d u) (iterExp d v)) := by
      cases max_cases ( iterExp d u ) ( iterExp d v ) <;> linarith [ Real.exp_le_exp.2 ( le_max_left ( iterExp d u ) ( iterExp d v ) ), Real.exp_le_exp.2 ( le_max_right ( iterExp d u ) ( iterExp d v ) ) ];
    -- By the properties of the exponential function and the induction hypothesis, we have $2 * \exp(\max(\iterExp d u, \iterExp d v)) \leq \exp(\max(\iterExp d u, \iterExp d v) + 1)$.
    have h_exp_bound : 2 * Real.exp (max (iterExp d u) (iterExp d v)) ≤ Real.exp (max (iterExp d u) (iterExp d v) + 1) := by
      rw [ Real.exp_add ];
      nlinarith [ Real.add_one_le_exp 1, Real.exp_pos ( max ( iterExp d u ) ( iterExp d v ) ) ];
    nontriviality;
    convert h_exp.trans h_exp_bound |> le_trans <| Real.exp_le_exp.mpr _ using 1;
    cases max_cases ( iterExp d u ) ( iterExp d v ) <;> linarith [ show 1 ≤ iterExp d u from Nat.le_induction ( by norm_num [ iterExp ] ; positivity ) ( fun k hk ih => by rw [ iterExp ] ; exact Real.one_le_exp ( by linarith ) ) d hd, show 1 ≤ iterExp d v from Nat.le_induction ( by norm_num [ iterExp ] ; positivity ) ( fun k hk ih => by rw [ iterExp ] ; exact Real.one_le_exp ( by linarith ) ) d hd ]

/-
Product of two iterExp terms at level d is bounded by iterExp d of a combined argument.
    For d = 0: C₁·x^N₁ · C₂·x^N₂ = C₁C₂·x^(N₁+N₂).
    For d ≥ 1: uses exp(a)·exp(b) = exp(a+b) and sum absorption.
-/
theorem iterExp_mul_bound {d : ℕ} (hd : 1 ≤ d) {u v : ℝ} (hu : 0 ≤ u) (hv : 0 ≤ v) :
    iterExp d u * iterExp d v ≤ iterExp d (u + v + 1) := by
  rcases d with ( _ | _ | d ) <;> norm_num [ iterExp ] at *;
  · rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by linarith );
  · rw [ ← Real.exp_add ];
    gcongr;
    refine' le_trans ( iterExp_sum_le_iterExp_max_succ ( Nat.succ_pos d ) ( by positivity ) ( by positivity ) ) _;
    exact Real.exp_le_exp.mpr ( iterExp_mono _ ( by cases max_cases u v <;> linarith ) )

/-
Product of positive envelope-bounded functions stays envelope-bounded.
    Requires eventual positivity of both f and g.
-/
theorem hasReciprocalEnvelope_mul_pos {d : ℕ} {f g : ℝ → ℝ}
    (hf : HasReciprocalEnvelope d f) (hg : HasReciprocalEnvelope d g)
    (hfpos : ∃ X : ℝ, ∀ x, x ≥ X → 0 < f x)
    (hgpos : ∃ X : ℝ, ∀ x, x ≥ X → 0 < g x) :
    HasReciprocalEnvelope d (fun x => f x * g x) := by
  obtain ⟨ C₁, hC₁, N₁, X₁, hX₁, h₁ ⟩ := hf
  obtain ⟨ C₂, hC₂, N₂, X₂, hX₂, h₂ ⟩ := hg
  obtain ⟨ Xf, hfpos' ⟩ := hfpos
  obtain ⟨ Xg, hgpos' ⟩ := hgpos;
  by_cases hd : 1 ≤ d;
  · refine' ⟨ ( C₁ + C₂ + 1 ), by positivity, N₁ + N₂ + 1, Max.max ( Max.max ( Max.max ( Max.max X₁ X₂ ) Xf ) Xg ) 1, by positivity, fun x hx => _ ⟩;
    -- Apply the iterExp_mul_bound lemma to combine the bounds.
    have h_mul_bound : iterExp d (C₁ * x ^ N₁) * iterExp d (C₂ * x ^ N₂) ≤ iterExp d ((C₁ + C₂ + 1) * x ^ (N₁ + N₂ + 1)) := by
      refine' le_trans ( iterExp_mul_bound hd _ _ ) _;
      · exact mul_nonneg hC₁.le ( pow_nonneg ( by linarith [ le_max_right ( max ( max ( max X₁ X₂ ) Xf ) Xg ) 1 ] ) _ );
      · exact mul_nonneg hC₂.le ( pow_nonneg ( by linarith [ le_max_right ( max ( max ( max X₁ X₂ ) Xf ) Xg ) 1 ] ) _ );
      · refine' iterExp_mono d _;
        rw [ add_mul, add_mul ];
        gcongr <;> norm_num at *;
        · linarith;
        · grind;
        · linarith;
        · linarith;
        · exact one_le_pow₀ hx.2;
    simp_all +decide [ mul_comm ];
    exact ⟨ le_trans ( mul_le_mul ( h₁ x hx.1.1.1.1 |>.1 ) ( h₂ x hx.1.1.1.2 |>.1 ) ( by linarith [ hgpos' x hx.1.2 ] ) ( by exact le_trans ( by linarith [ hfpos' x hx.1.1.2 ] ) ( h₁ x hx.1.1.1.1 |>.1 ) ) ) h_mul_bound, le_trans ( mul_le_mul ( h₁ x hx.1.1.1.1 |>.2 ) ( h₂ x hx.1.1.1.2 |>.2 ) ( by exact inv_nonneg.2 ( le_of_lt ( hgpos' x hx.1.2 ) ) ) ( by exact le_trans ( by linarith [ hfpos' x hx.1.1.2 ] ) ( h₁ x hx.1.1.1.1 |>.1 ) ) ) h_mul_bound ⟩;
  · interval_cases d ; norm_num at *;
    refine' ⟨ C₁ * C₂ + 1, by positivity, N₁ + N₂, Max.max X₁ ( Max.max X₂ ( Max.max Xf Xg + 1 ) ), by positivity, fun x hx => _ ⟩;
    simp +zetaDelta at *;
    constructor <;> ring_nf;
    · nlinarith [ h₁ x hx.1, h₂ x hx.2.1, show 0 < x ^ N₁ * x ^ N₂ by exact mul_pos ( pow_pos ( by linarith [ le_max_left Xf Xg, le_max_right Xf Xg ] ) _ ) ( pow_pos ( by linarith [ le_max_left Xf Xg, le_max_right Xf Xg ] ) _ ), hfpos' x ( by linarith [ le_max_left Xf Xg, le_max_right Xf Xg ] ), hgpos' x ( by linarith [ le_max_left Xf Xg, le_max_right Xf Xg ] ) ];
    · nlinarith [ h₁ x hx.1, h₂ x hx.2.1, inv_pos.2 ( hfpos' x ( by linarith [ le_max_left Xf Xg ] ) ), inv_pos.2 ( hgpos' x ( by linarith [ le_max_right Xf Xg ] ) ), mul_pos ( inv_pos.2 ( hfpos' x ( by linarith [ le_max_left Xf Xg ] ) ) ) ( inv_pos.2 ( hgpos' x ( by linarith [ le_max_right Xf Xg ] ) ) ), pow_nonneg ( by linarith [ le_max_left Xf Xg, le_max_right Xf Xg ] : 0 ≤ x ) N₁, pow_nonneg ( by linarith [ le_max_left Xf Xg, le_max_right Xf Xg ] : 0 ≤ x ) N₂ ]

/-- Multiplication preserves reciprocal envelopes (at the max level).
    Requires eventual positivity. -/
theorem HasReciprocalEnvelope.mul {d₁ d₂ : ℕ} {f g : ℝ → ℝ}
    (hf : HasReciprocalEnvelope d₁ f) (hg : HasReciprocalEnvelope d₂ g)
    (hfpos : ∃ X : ℝ, ∀ x, x ≥ X → 0 < f x)
    (hgpos : ∃ X : ℝ, ∀ x, x ≥ X → 0 < g x) :
    HasReciprocalEnvelope (max d₁ d₂) (fun x => f x * g x) :=
  hasReciprocalEnvelope_mul_pos (hf.mono (le_max_left _ _)) (hg.mono (le_max_right _ _)) hfpos hgpos

/-
Exponentiation increases the reciprocal envelope level by exactly 1.
    If `f` has a reciprocal envelope at level `d`, then `exp ∘ f` has one
    at level `d + 1`.

    The upper bound: `exp(f(x)) ≤ exp(iterExp d (C·x^N)) = iterExp (d+1) (C·x^N)`.
    The lower bound: `1/exp(f(x)) = exp(-f(x)) ≤ 1` since `f(x) > 0` on positive
    reals, and `1 ≤ iterExp (d+1) (C·x^N)`.
-/
theorem HasReciprocalEnvelope.exp_comp {d : ℕ} {f : ℝ → ℝ}
    (hf : HasReciprocalEnvelope d f)
    (hpos : ∃ X₀ : ℝ, ∀ x, x ≥ X₀ → 0 < f x) :
    HasReciprocalEnvelope (d + 1) (fun x => Real.exp (f x)) := by
  obtain ⟨ C, hC_pos, N, X₀, hX₀_pos, h ⟩ := hf;
  refine' ⟨ C, hC_pos, N, Max.max X₀ hpos.choose, lt_max_of_lt_left hX₀_pos, fun x hx => _ ⟩;
  simp_all +decide [ iterExp_succ ];
  rw [ ← Real.exp_neg ] ; exact Real.exp_le_exp.mpr ( neg_le_iff_add_nonneg.mpr <| by linarith [ hpos.choose_spec x hx.2, h x hx.1 ] )

/-! ## Main Envelope Theorem -/

/-
**Every positive-constant expression of depth `d` has a reciprocal envelope
    at level `d`.**

    This is proved by structural induction on the expression:
    - `var`: level-0 envelope (identity is polynomially bounded)
    - `const c` (c > 0): level-0 envelope (constant is bounded)
    - `mul a b`: `max(d_a, d_b)`-level envelope by `HasReciprocalEnvelope.mul`
    - `inv a`: same level as `a` by `HasReciprocalEnvelope.inv`
    - `exp a`: level `d_a + 1` by `HasReciprocalEnvelope.exp_comp`
-/
theorem hasReciprocalEnvelope_of_posConsts (e : PosExpr) (hpc : e.posConsts) :
    HasReciprocalEnvelope e.depth (fun x => e.eval x) := by
  induction' e with e ih;
  · convert hasReciprocalEnvelope_var using 1;
  · convert hasReciprocalEnvelope_const e hpc;
  · rename_i a ha₁ ha₂;
    have hpc1 : ih.posConsts := by cases hpc; tauto
    have hpc2 : a.posConsts := by cases hpc; tauto
    exact HasReciprocalEnvelope.mul (ha₁ hpc1) (ha₂ hpc2)
      ⟨1, fun x hx => eval_pos_of_posConsts ih hpc1 (by positivity)⟩
      ⟨1, fun x hx => eval_pos_of_posConsts a hpc2 (by positivity)⟩;
  · rename_i a ih;
    convert HasReciprocalEnvelope.inv ( ih hpc ) using 1;
  · rename_i e ih;
    convert HasReciprocalEnvelope.exp_comp ( ih hpc ) _ using 1;
    · exact add_comm _ _;
    · exact ⟨ 1, fun x hx => eval_pos_of_posConsts e hpc <| by positivity ⟩

/-! ## Depth Rigidity: The Flagship Theorem -/

/-
**iterExp n does not have a reciprocal envelope at any level d < n.**
    This is the separation argument: `iterExp n x` grows too fast to be bounded
    by `iterExp d (C · x^N)` for any constants `C, N` when `d < n`.
-/
theorem iterExp_no_low_envelope {d n : ℕ} (hdn : d < n) :
    ¬ HasReciprocalEnvelope d (iterExp n) := by
  intro h
  obtain ⟨C, hC_pos, N, X₀, hX₀_pos, h_bound⟩ := h
  obtain ⟨X₁, hX₁_pos, h_poly⟩ := iterExp_poly_lt_iterExp_succ d C N;
  -- Since $d + 1 \leq n$, by iterExp_mono and level monotonicity, we have $\text{iterExp} (d + 1) x \leq \text{iterExp} n x$ for all $x \geq 0$.
  have h_mono : ∀ x : ℝ, 0 ≤ x → iterExp (d + 1) x ≤ iterExp n x := by
    intro x hx_nonneg
    have h_mono_step : ∀ m : ℕ, d + 1 ≤ m → m ≤ n → iterExp (d + 1) x ≤ iterExp m x := by
      intro m hm₁ hm₂; induction hm₁ <;> simp_all +decide [ iterExp ] ;
      exact le_trans ( le_trans ( by norm_num ) ( Real.add_one_le_exp _ ) ) ( ‹ ( _ : ℕ ) ≤ n → Real.exp ( iterExp d x ) ≤ iterExp _ x › ( by linarith ) );
    exact h_mono_step n hdn ( le_refl n );
  linarith [ h_bound ( Max.max X₀ X₁ ) ( le_max_left _ _ ), h_poly ( Max.max X₀ X₁ ) ( le_max_right _ _ ), h_mono ( Max.max X₀ X₁ ) ( le_max_of_le_left hX₀_pos.le ) ]

/-
**Depth rigidity with inversions (flagship theorem).**

    For every expression `e` in the full EML language (with inversions) over
    positive reals that computes `iterExp n` exactly on all `x > 0`, the depth
    of `e` must be at least `n`.

    This is the definitive formalization that inversion cannot collapse the
    exponential depth hierarchy. Division, despite allowing identities like
    `exp(f)·exp(-f) = 1` and `exp(f)/exp(g) = exp(f-g)`, cannot compress
    the tower height of iterated exponentials.

    **Proof**: By contradiction. If `depth e < n`, then by `hasReciprocalEnvelope_of_posConsts`,
    `e.eval` has a reciprocal envelope at level `depth e < n`. But `e.eval = iterExp n`
    on positive reals, and `iterExp n` does not have any such envelope by
    `iterExp_no_low_envelope`. Contradiction.
-/
theorem iterExp_depth_rigidity_full {e : PosExpr} {n : ℕ}
    (hpc : e.posConsts)
    (hcomp : ComputesOnPos e (iterExp n)) :
    n ≤ e.depth := by
  have := @hasReciprocalEnvelope_of_posConsts;
  specialize this e hpc;
  contrapose! this;
  convert iterExp_no_low_envelope this using 1;
  constructor <;> intro h <;> rcases h with ⟨ C, hC, N, X₀, hX₀, h ⟩ <;> use C, hC, N, Max.max X₀ 1 <;> simp_all +decide;
  · intro x hx₁ hx₂; specialize h x hx₁; rw [ hcomp x ( by linarith ) ] at h; aesop;
  · intro x hx₁ hx₂; specialize h x hx₁; rw [ hcomp x ( by linarith ) ] at *; aesop;

/-! ## Corollaries -/

/-- Growth rank lower bound for iterExp computation. -/
theorem iterExp_growthRank_lower_bound {e : PosExpr} {n : ℕ}
    (hpc : e.posConsts)
    (hcomp : ComputesOnPos e (iterExp n)) :
    n ≤ e.growthRank := by
  rw [growthRank_eq_depth]
  exact iterExp_depth_rigidity_full hpc hcomp

/-- LogTameIndex lower bound for iterExp computation. -/
theorem iterExp_logTameIndex_lower_bound {e : PosExpr} {n : ℕ}
    (hpc : e.posConsts)
    (hcomp : ComputesOnPos e (iterExp n)) :
    n ≤ e.logTameIndex := by
  rw [logTameIndex_eq_growthRank]
  exact iterExp_growthRank_lower_bound hpc hcomp

/-- The canonical expression achieves the optimal depth — it is tight. -/
theorem canonIterExp_optimal (n : ℕ) :
    (canonIterExp n).depth = n ∧
    ComputesOnPos (canonIterExp n) (iterExp n) ∧
    (canonIterExp n).posConsts ∧
    (canonIterExp n).invFree := by
  exact ⟨canonIterExp_depth n,
         fun x _ => canonIterExp_eval n x,
         canonIterExp_posConsts n,
         canonIterExp_invFree n⟩

/-- No expression of depth less than `n` can compute `iterExp n`, even with inversions.
    Contrapositive formulation for impossibility results. -/
theorem no_shallow_iterExp {n : ℕ} :
    ¬ ∃ e : PosExpr, e.posConsts ∧ e.depth < n ∧ ComputesOnPos e (iterExp n) := by
  intro ⟨e, hpc, hdepth, hcomp⟩
  have := iterExp_depth_rigidity_full hpc hcomp
  omega

/-! ## Cross-Domain: Compiler Optimization Impossibility -/

/-- **Compiler optimization lower bound.**

    Any semantics-preserving optimizer for positive-real EML expressions cannot
    reduce the depth of `iterExp n` below `n`. This formalizes an impossibility
    result for expression simplification with division.

    Interpretation: no sequence of algebraic rewrites using `a * (1/a) = 1`,
    `exp(a) * exp(b) = exp(a+b)`, `1/exp(a) = exp(-a)`, etc., can compress
    the n-fold exponential tower to fewer than n nested exponentials. -/
theorem compiler_cannot_compress_iterExp (n : ℕ)
    (optimizer : PosExpr → PosExpr)
    (h_preserves : ∀ e : PosExpr, e.posConsts →
      (optimizer e).posConsts ∧ ∀ x, 0 < x → (optimizer e).eval x = e.eval x) :
    n ≤ (optimizer (canonIterExp n)).depth := by
  have hpc := (h_preserves (canonIterExp n) (canonIterExp_posConsts n)).1
  have hsem := (h_preserves (canonIterExp n) (canonIterExp_posConsts n)).2
  apply iterExp_depth_rigidity_full hpc
  intro x hx
  rw [hsem x hx, canonIterExp_eval]

/-! ## Falsifiable Conjecture: Strict Hierarchy -/

/-- **Conjecture (strict depth hierarchy with inversions):**
    For every `d`, the function `iterExp (d+1)` cannot be computed by any
    depth-`d` expression over positive reals, even with inversions.

    This is an immediate consequence of `iterExp_depth_rigidity_full`,
    stated explicitly as a testable prediction. -/
theorem strict_depth_hierarchy (d : ℕ) :
    ¬ ∃ e : PosExpr, e.posConsts ∧ e.depth ≤ d ∧
      ComputesOnPos e (iterExp (d + 1)) := by
  intro ⟨e, hpc, hdepth, hcomp⟩
  have := iterExp_depth_rigidity_full hpc hcomp
  omega

end