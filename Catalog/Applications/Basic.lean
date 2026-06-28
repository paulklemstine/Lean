import Mathlib

/-!
# Circuit-complexity foundations and exp-log network universal approximation

This file is the foundational `Basic` module of the `Catalog.Novelty.CircuitComplexity`
development.  It collects two pieces of machinery:

## 1. Monotone Boolean circuits (`MCircuit`)

The inductive type `MCircuit ι` of monotone Boolean circuits over inputs indexed by
`ι`, together with its semantics `eval`, its `size` (number of nodes), and its
`depth`.  These are the primitives consumed by the companion files
`Catalog.Novelty.CircuitComplexity.Approximation` (Razborov's approximation method)
and `Catalog.Novelty.CircuitComplexity.KarchmerWigderson`.

## 2. Exp-log networks and a multivariate Jackson-type theorem

The arithmetic-circuit analogue: *exp-log networks*, built from the **LogSumExp**
(`logSumExp`) smooth-maximum primitive.  We prove the basic *smoothing error
analysis*

* `sup'_le_logSumExp` : `LSE` is a lower bound for the maximum,
* `logSumExp_le_sup'_add` : `LSE` overshoots the maximum by at most `log (#s) / c`,

relying only on **monotonicity of `exp`/`log`**, **positivity of the
log-sum-exp argument**, and **`Finset` sum inequalities** (`single_le_sum`,
`sum_le_card_nsmul`).  Smoothing the absolute value (`smoothAbs`) the same way,
we assemble a genuine exp-log network

`expLogNet c L f P x = LSE_{p∈P} ( f p - L · Σ_i smoothAbs (xᵢ - pᵢ) )`

and prove the **multivariate Jackson-type approximation theorem**
(`jackson_expLog_width`): for every L¹-Lipschitz `f : ℝⁿ → ℝ` and every `ε > 0`
there is an exp-log network over a grid `P` of width
`#P ≤ (m+1)^n = O(ε^{-n})` (the `α = 1` instance of the conjectured
`O(ε^{-n/α})` rate) that approximates `f` within `ε` uniformly on the unit cube.

The proof is non-circular: it uses only the LogSumExp smoothing bounds above,
the Lipschitz hypothesis, and elementary `Finset`/grid combinatorics.
-/

noncomputable section

open Real Finset

namespace CircuitComplexity

/-! ## Monotone Boolean circuits -/

/-- Monotone Boolean circuits over inputs indexed by `ι`: variables, the two
constants, and binary AND/OR gates (no negation). -/
inductive MCircuit (ι : Type*) where
  | var : ι → MCircuit ι
  | top : MCircuit ι
  | bot : MCircuit ι
  | and : MCircuit ι → MCircuit ι → MCircuit ι
  | or  : MCircuit ι → MCircuit ι → MCircuit ι

namespace MCircuit

variable {ι : Type*}

/-- Boolean semantics of a monotone circuit. -/
def eval : MCircuit ι → (ι → Bool) → Bool
  | var i,  x => x i
  | top,    _ => true
  | bot,    _ => false
  | and a b, x => eval a x && eval b x
  | or a b,  x => eval a x || eval b x

/-- The size (number of nodes) of a circuit. -/
def size : MCircuit ι → ℕ
  | var _  => 1
  | top    => 1
  | bot    => 1
  | and a b => size a + size b + 1
  | or a b  => size a + size b + 1

/-- The depth of a circuit. -/
def depth : MCircuit ι → ℕ
  | var _  => 0
  | top    => 0
  | bot    => 0
  | and a b => max (depth a) (depth b) + 1
  | or a b  => max (depth a) (depth b) + 1

@[simp] theorem eval_var (i : ι) (x : ι → Bool) : (var i).eval x = x i := rfl
@[simp] theorem eval_top (x : ι → Bool) : (top : MCircuit ι).eval x = true := rfl
@[simp] theorem eval_bot (x : ι → Bool) : (bot : MCircuit ι).eval x = false := rfl
@[simp] theorem eval_and (a b : MCircuit ι) (x : ι → Bool) :
    (and a b).eval x = (a.eval x && b.eval x) := rfl
@[simp] theorem eval_or (a b : MCircuit ι) (x : ι → Bool) :
    (or a b).eval x = (a.eval x || b.eval x) := rfl

end MCircuit

/-! ## Exp-log networks: the LogSumExp smoothing primitive -/

namespace ExpLog

variable {α : Type*}

/-- The (scaled) **LogSumExp** smooth maximum with sharpness `c`:
`logSumExp c s a = (1/c) · log (Σ_{i∈s} exp (c · a i))`.  As `c → ∞` it converges
to `maxᵢ a i`. -/
def logSumExp (c : ℝ) (s : Finset α) (a : α → ℝ) : ℝ :=
  (1 / c) * Real.log (∑ i ∈ s, Real.exp (c * a i))

/-
Positivity of the log-sum-exp argument on a nonempty index set.
-/
theorem sumExp_pos (c : ℝ) {s : Finset α} (hs : s.Nonempty) (a : α → ℝ) :
    0 < ∑ i ∈ s, Real.exp (c * a i) := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hs

/-
**LogSumExp lower bound (positivity of the gap).**  The smooth maximum is at
least the true maximum.  Uses `single_le_sum` (one summand bounds the whole
positive sum) and monotonicity of `log`.
-/
theorem sup'_le_logSumExp (c : ℝ) (hc : 0 < c) {s : Finset α} (hs : s.Nonempty)
    (a : α → ℝ) : s.sup' hs a ≤ logSumExp c s a := by
  rw [ logSumExp ];
  rw [ one_div, inv_mul_eq_div, le_div_iff₀' hc ];
  rw [ Real.le_log_iff_exp_le ( Finset.sum_pos ( fun x _ => Real.exp_pos _ ) hs ) ];
  obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_sup' hs a; exact le_trans ( by aesop ) ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( c * a i ) ) hi.1 ) ;

/-
**LogSumExp smoothing error bound.**  The smooth maximum exceeds the true
maximum by at most `log (#s) / c`.  Uses `sum_le_card_nsmul` (every summand is
bounded by `exp (c · max)`) and monotonicity of `log`.
-/
theorem logSumExp_le_sup'_add (c : ℝ) (hc : 0 < c) {s : Finset α} (hs : s.Nonempty)
    (a : α → ℝ) : logSumExp c s a ≤ s.sup' hs a + Real.log s.card / c := by
  unfold logSumExp;
  rw [ div_mul_eq_mul_div, div_le_iff₀' hc ];
  rw [ mul_add, mul_div_cancel₀ _ hc.ne' ];
  rw [ one_mul, add_comm ];
  rw [ ← Real.log_exp ( c * s.sup' hs a ), ← Real.log_mul ( by positivity ) ( by positivity ), Real.log_le_log_iff ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hs ) ( by positivity ) ];
  convert Finset.sum_le_card_nsmul _ _ _ _ ; aesop;
  · infer_instance;
  · exact fun x hx => Real.exp_le_exp.2 ( mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun x => a x ) hx ) hc.le )

/-! ## Smoothing the absolute value -/

/-- Smooth absolute value: `smoothAbs c t = (1/c) log (exp (c t) + exp (-(c t)))`.
This is `logSumExp` of the two affine pieces `t` and `-t`, hence representable in
an exp-log network. -/
def smoothAbs (c t : ℝ) : ℝ :=
  (1 / c) * Real.log (Real.exp (c * t) + Real.exp (-(c * t)))

/-
The smooth absolute value dominates `|t|` (log-sum-exp ≥ max).
-/
theorem abs_le_smoothAbs (c : ℝ) (hc : 0 < c) (t : ℝ) : |t| ≤ smoothAbs c t := by
  unfold smoothAbs;
  rw [ one_div, inv_mul_eq_div, le_div_iff₀ hc ];
  cases abs_cases t <;> nlinarith [ Real.add_one_le_exp ( c * t ), Real.add_one_le_exp ( - ( c * t ) ), Real.log_exp ( c * t ), Real.log_exp ( - ( c * t ) ), Real.log_le_log ( by positivity ) ( show Real.exp ( c * t ) + Real.exp ( - ( c * t ) ) ≥ Real.exp ( c * t ) by linarith [ Real.exp_pos ( c * t ), Real.exp_pos ( - ( c * t ) ) ] ), Real.log_le_log ( by positivity ) ( show Real.exp ( c * t ) + Real.exp ( - ( c * t ) ) ≥ Real.exp ( - ( c * t ) ) by linarith [ Real.exp_pos ( c * t ), Real.exp_pos ( - ( c * t ) ) ] ) ]

/-
The smooth absolute value overshoots `|t|` by at most `log 2 / c`.
-/
theorem smoothAbs_le_abs_add (c : ℝ) (hc : 0 < c) (t : ℝ) :
    smoothAbs c t ≤ |t| + Real.log 2 / c := by
  unfold smoothAbs; ring_nf ;
  field_simp;
  rw [ Real.log_le_iff_le_exp, Real.exp_add, Real.exp_log ] <;> try positivity;
  cases abs_cases t <;> simp +decide [ * ] <;> ring_nf;
  · linarith [ Real.exp_le_exp.2 ( show - ( c * t ) ≤ c * t by nlinarith ) ];
  · nlinarith [ Real.exp_pos ( c * t ), Real.exp_le_exp.2 ( by nlinarith : c * t ≤ - ( c * t ) ) ]

/-! ## Multivariate exp-log networks and the Jackson rate -/

variable {n : ℕ}

/-- The `L¹` distance on `ℝⁿ`. -/
def dist1 (x p : Fin n → ℝ) : ℝ := ∑ i, |x i - p i|

theorem dist1_nonneg (x p : Fin n → ℝ) : 0 ≤ dist1 x p :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

/-- The affine-tent value at a center `p`: `f p - L · Σ_i smoothAbs (xᵢ - pᵢ)`.
A single exp-log "neuron" centred at the grid point `p`. -/
def innerVal (c L : ℝ) (f : (Fin n → ℝ) → ℝ) (p x : Fin n → ℝ) : ℝ :=
  f p - L * ∑ i, smoothAbs c (x i - p i)

/-- The **exp-log network**: a smooth maximum (`logSumExp`) over centres `p ∈ P`
of the tent neurons `innerVal`. -/
def expLogNet (c L : ℝ) (f : (Fin n → ℝ) → ℝ) (P : Finset (Fin n → ℝ))
    (x : Fin n → ℝ) : ℝ :=
  logSumExp c P (fun p => innerVal c L f p x)

/-- The ideal (non-smooth) lower envelope `maxₚ (f p - L · d₁(x,p))`. -/
def lowerEnv (L : ℝ) (f : (Fin n → ℝ) → ℝ) (P : Finset (Fin n → ℝ))
    (hP : P.Nonempty) (x : Fin n → ℝ) : ℝ :=
  P.sup' hP (fun p => f p - L * dist1 x p)

/-
Each tent neuron underestimates the ideal tent (`smoothAbs ≥ |·|`).
-/
theorem innerVal_le (c L : ℝ) (hc : 0 < c) (hL : 0 ≤ L) (f : (Fin n → ℝ) → ℝ)
    (p x : Fin n → ℝ) : innerVal c L f p x ≤ f p - L * dist1 x p := by
  exact sub_le_sub_left ( mul_le_mul_of_nonneg_left ( Finset.sum_le_sum fun i _ => by simpa using abs_le_smoothAbs c hc ( x i - p i ) ) hL ) _

/-
Each tent neuron is within `L · n · log 2 / c` below the ideal tent.
-/
theorem le_innerVal (c L : ℝ) (hc : 0 < c) (hL : 0 ≤ L) (f : (Fin n → ℝ) → ℝ)
    (p x : Fin n → ℝ) :
    f p - L * dist1 x p - L * n * (Real.log 2 / c) ≤ innerVal c L f p x := by
  unfold innerVal; ring_nf;
  have h_sum_le : ∑ i, smoothAbs c (x i - p i) ≤ ∑ i, (|x i - p i| + Real.log 2 / c) := by
    exact Finset.sum_le_sum fun i _ => smoothAbs_le_abs_add c hc _;
  simp_all +decide [ Finset.sum_add_distrib, dist1 ];
  ring_nf at *; nlinarith;

/-
The lower envelope never exceeds `f` (Lipschitz ⇒ each tent ≤ `f x`).
-/
theorem lowerEnv_le_f (L : ℝ) (f : (Fin n → ℝ) → ℝ)
    (hf : ∀ x y, |f x - f y| ≤ L * dist1 x y) (P : Finset (Fin n → ℝ))
    (hP : P.Nonempty) (x : Fin n → ℝ) : lowerEnv L f P hP x ≤ f x := by
  unfold lowerEnv;
  simp +zetaDelta at *;
  intro p hp; specialize hf p x; rw [ abs_le ] at hf; rw [ dist1 ] at *
  have h2 := hf.2
  rw [ show (∑ i, |p i - x i|) = ∑ i, |x i - p i| from
        Finset.sum_congr rfl fun i _ => abs_sub_comm _ _ ] at h2
  linarith

/-
If some centre `p₀ ∈ P` is within `L¹`-distance `h` of `x`, the lower
envelope is at least `f x - 2 L h`.
-/
theorem f_sub_le_lowerEnv (L : ℝ) (hL : 0 ≤ L) (f : (Fin n → ℝ) → ℝ)
    (hf : ∀ x y, |f x - f y| ≤ L * dist1 x y) (P : Finset (Fin n → ℝ))
    (hP : P.Nonempty) (x : Fin n → ℝ) (h : ℝ) (p₀ : Fin n → ℝ) (hp₀ : p₀ ∈ P)
    (hnear : dist1 x p₀ ≤ h) : f x - 2 * L * h ≤ lowerEnv L f P hP x := by
  refine' le_trans _ ( Finset.le_sup' _ hp₀ );
  nlinarith [ abs_le.mp ( hf x p₀ ) ]

/-
**Pointwise exp-log Jackson bound.**  If `f` is `L`-Lipschitz (in `L¹`) and
some centre of `P` lies within `L¹`-distance `h` of `x`, the exp-log network
approximates `f x` with error at most `2 L h + L n (log 2)/c + log(#P)/c`.
-/
theorem expLogNet_sub_f_abs_le (c L : ℝ) (hc : 0 < c) (hL : 0 ≤ L)
    (f : (Fin n → ℝ) → ℝ) (hf : ∀ x y, |f x - f y| ≤ L * dist1 x y)
    (P : Finset (Fin n → ℝ)) (hP : P.Nonempty) (x : Fin n → ℝ) (h : ℝ)
    (p₀ : Fin n → ℝ) (hp₀ : p₀ ∈ P) (hnear : dist1 x p₀ ≤ h) :
    |expLogNet c L f P x - f x|
      ≤ 2 * L * h + L * n * (Real.log 2 / c) + Real.log P.card / c := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · -- From Step 1, we have `expLogNet ≤ S + Lc`.
    have h_expLogNet_le_S_plus_Lc : expLogNet c L f P x ≤ (P.sup' hP (fun p => innerVal c L f p x)) + Real.log P.card / c := by
      convert logSumExp_le_sup'_add c hc hP ( fun p => innerVal c L f p x ) using 1;
    -- From Step 2, we have `S ≤ g`.
    have h_S_le_g : (P.sup' hP (fun p => innerVal c L f p x)) ≤ lowerEnv L f P hP x := by
      exact Finset.sup'_le _ _ fun p hp => by exact le_trans ( innerVal_le c L hc hL f p x ) ( Finset.le_sup' ( fun p => f p - L * dist1 x p ) hp ) ;
    -- From Step 3, we have `g ≤ f x`.
    have h_g_le_f : lowerEnv L f P hP x ≤ f x :=
      lowerEnv_le_f L f hf P hP x
    nlinarith [ show 0 ≤ L * n * ( Real.log 2 / c ) by positivity, show 0 ≤ 2 * L * h by exact mul_nonneg ( mul_nonneg zero_le_two hL ) ( le_trans ( dist1_nonneg _ _ ) hnear ) ];
  · -- By definition of `expLogNet`, we know that `expLogNet c L f P x ≥ S`.
    have h_exp_log_net_ge_S : expLogNet c L f P x ≥ P.sup' hP (fun p => innerVal c L f p x) := by
      apply sup'_le_logSumExp c hc hP (fun p => innerVal c L f p x);
    -- By definition of `innerVal`, we know that `innerVal c L f p₀ x ≤ f p₀ - L * dist1 x p₀`.
    have h_inner_val_le : P.sup' hP (fun p => innerVal c L f p x) ≥ f p₀ - L * dist1 x p₀ - L * n * (Real.log 2 / c) := by
      exact le_trans ( le_innerVal c L hc hL f p₀ x ) ( Finset.le_sup' ( fun p => innerVal c L f p x ) hp₀ );
    nlinarith [ abs_le.mp ( hf x p₀ ), show 0 ≤ Real.log P.card / c by exact div_nonneg ( Real.log_natCast_nonneg _ ) hc.le ]

/-! ## The product grid on the unit cube -/

/-- The uniform product grid of resolution `m` on the unit cube `[0,1]ⁿ`:
all points whose coordinates are of the form `k/m`, `0 ≤ k ≤ m`. -/
def unitGrid (n m : ℕ) : Finset (Fin n → ℝ) :=
  Fintype.piFinset (fun _ : Fin n => (Finset.range (m + 1)).image (fun k : ℕ => (k : ℝ) / m))

/-- The product grid is always nonempty (each coordinate factor contains `0`). -/
theorem unitGrid_nonempty (n m : ℕ) : (unitGrid n m).Nonempty := by
  refine' Fintype.piFinset_nonempty.mpr fun _ => _;
  exact ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_range.mpr ( Nat.succ_pos _ ) ) ⟩

/-
The grid has at most `(m+1)^n` points: the `O(ε^{-n})` width count.
-/
theorem unitGrid_card_le (n m : ℕ) : (unitGrid n m).card ≤ (m + 1) ^ n := by
  -- The cardinality of the product of finite sets is the product of their cardinalities.
  have h_card : (unitGrid n m).card = ∏ i : Fin n, ((Finset.range (m + 1)).image (fun k : ℕ => (k : ℝ) / m)).card := by
    convert Fintype.card_piFinset _;
  exact h_card.symm ▸ le_trans ( Finset.prod_le_prod' fun _ _ => Finset.card_image_le ) ( by norm_num )

/-
**Net property.**  Every point of the unit cube lies within `L¹`-distance
`n / (2 m)` of some grid point.
-/
theorem unitGrid_net (n m : ℕ) (hm : 1 ≤ m) (x : Fin n → ℝ)
    (hx : ∀ i, x i ∈ Set.Icc (0 : ℝ) 1) :
    ∃ p ∈ unitGrid n m, dist1 x p ≤ n / (2 * m) := by
  -- Define the grid point p as the ^^rinted values of the coordinates of x, scaled by m and rounded to the nearest integer.
  obtain ⟨p, hp⟩ : ∃ p : Fin n → ℤ, (∀ i, 0 ≤ p i ∧ p i ≤ m) ∧ ∀ i, |(x i) - ((p i) : ℝ) / m| ≤ 1 / (2 * m) := by
    refine' ⟨ fun i => ⌊x i * m + 1 / 2⌋, _, _ ⟩ <;> norm_num;
    · exact fun i => ⟨ Int.floor_nonneg.2 <| by nlinarith [ Set.mem_Icc.1 ( hx i ), show ( m : ℝ ) ≥ 1 by norm_cast ], Int.le_of_lt_add_one <| Int.floor_lt.2 <| by norm_num; nlinarith [ Set.mem_Icc.1 ( hx i ), show ( m : ℝ ) ≥ 1 by norm_cast ] ⟩;
    · intro i; rw [ abs_le ] ; constructor <;> nlinarith [ hx i |>.1, hx i |>.2, show ( m : ℝ ) ≥ 1 by norm_cast, mul_div_cancel₀ ( ⌊x i * m + 1 / 2⌋ : ℝ ) ( by positivity : ( m : ℝ ) ≠ 0 ), Int.floor_le ( x i * m + 1 / 2 ), Int.lt_floor_add_one ( x i * m + 1 / 2 ), mul_inv_cancel₀ ( by positivity : ( m : ℝ ) ≠ 0 ) ] ;
  refine' ⟨ fun i => ( p i : ℝ ) / m, _, _ ⟩ <;> simp_all +decide [ unitGrid ];
  · exact fun i => ⟨ Int.natAbs ( p i ), by linarith [ hp.1 i, abs_of_nonneg ( hp.1 i |>.1 ) ], by simp +decide [ abs_of_nonneg ( hp.1 i |>.1 ) ] ⟩;
  · refine' le_trans ( Finset.sum_le_sum fun i _ => hp.2 i ) _ ; norm_num ; ring_nf ; norm_num [ show m ≠ 0 by linarith ]

/-
**Multivariate Jackson-type universal approximation for exp-log networks.**

For every `L¹`-Lipschitz `f : ℝⁿ → ℝ` and every `ε > 0`, there is a sharpness
`c > 0`, a resolution `m ≥ 1`, and the corresponding exp-log network over the grid
`unitGrid n m` whose width satisfies `#(unitGrid n m) ≤ (m+1)^n = O(ε^{-n})` and
which approximates `f` within `ε` uniformly on the unit cube `[0,1]ⁿ`.  This is the
`α = 1` (Lipschitz) instance of the conjectured `O(ε^{-n/α})` width rate.
-/
theorem jackson_expLog_width (L : ℝ) (hL : 0 ≤ L) (f : (Fin n → ℝ) → ℝ)
    (hf : ∀ x y, |f x - f y| ≤ L * dist1 x y) (ε : ℝ) (hε : 0 < ε) :
    ∃ (c : ℝ) (m : ℕ), 0 < c ∧ 1 ≤ m ∧
      (unitGrid n m).card ≤ (m + 1) ^ n ∧
      ∀ x : Fin n → ℝ, (∀ i, x i ∈ Set.Icc (0 : ℝ) 1) →
        |expLogNet c L f (unitGrid n m) x - f x| ≤ ε := by
  -- Choose `m` such that `3 * L * n / ε ≤ m`.
  obtain ⟨m, hm⟩ : ∃ m : ℕ, 1 ≤ m ∧ 3 * L * n / ε ≤ (m : ℝ) := by
    exact ⟨ ⌈3 * L * n / ε⌉₊ + 1, by linarith, by push_cast; linarith [ Nat.le_ceil ( 3 * L * n / ε ) ] ⟩;
  -- Choose `c` such that `c * ε = 3 * ((n:ℝ)*Real.log ((m:ℝ) + 1) + L * (n:ℝ) * Real.log 2 + 1)`.
  obtain ⟨c, hc_pos, hc_eq⟩ : ∃ c : ℝ, 0 < c ∧ c * ε = 3 * ((n : ℝ) * Real.log ((m : ℝ) + 1) + L * (n : ℝ) * Real.log 2 + 1) := by
    exact ⟨ ( 3 * ( n * Real.log ( m + 1 ) + L * n * Real.log 2 + 1 ) ) / ε, div_pos ( by exact mul_pos zero_lt_three ( by exact add_pos_of_nonneg_of_pos ( add_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( Real.log_nonneg ( by linarith ) ) ) ( mul_nonneg ( mul_nonneg hL ( Nat.cast_nonneg _ ) ) ( Real.log_nonneg ( by norm_num ) ) ) ) zero_lt_one ) ) hε, by rw [ div_mul_cancel₀ _ hε.ne' ] ⟩;
  refine' ⟨ c, m, hc_pos, hm.1, unitGrid_card_le n m, fun x hx => _ ⟩;
  obtain ⟨p₀, hp₀mem, hp₀dist⟩ := unitGrid_net n m hm.1 x hx;
  refine' le_trans ( expLogNet_sub_f_abs_le c L hc_pos hL f hf ( unitGrid n m ) ( unitGrid_nonempty n m ) x ( n / ( 2 * m ) ) p₀ hp₀mem hp₀dist ) _;
  -- We'll use that $|(unitGrid n m).card| \leq (m + 1)^n$.
  have h_card : Real.log (unitGrid n m).card ≤ n * Real.log (m + 1) := by
    rw [ ← Real.log_pow ];
    gcongr;
    · exact Nat.cast_pos.mpr ( Finset.card_pos.mpr ⟨ p₀, hp₀mem ⟩ );
    · exact_mod_cast unitGrid_card_le n m;
  field_simp at *;
  rw [ div_add', mul_div, div_add', div_le_iff₀ ] <;> nlinarith [ show ( m : ℝ ) ≥ 1 by norm_cast; linarith, show ( 0 : ℝ ) ≤ L * n by positivity, show ( 0 : ℝ ) ≤ L * n * Real.log 2 by positivity, show ( 0 : ℝ ) ≤ n * Real.log ( m + 1 ) by exact mul_nonneg ( Nat.cast_nonneg _ ) ( Real.log_nonneg ( by linarith ) ) ]

end ExpLog

end CircuitComplexity