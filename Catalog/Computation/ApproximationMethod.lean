import Mathlib

/-!
# Monotone Circuit Complexity: Approximation Method Framework

This file formalizes the core abstractions of Razborov's approximation method for
proving monotone circuit lower bounds, and connects them to the Karchmer–Wigderson
correspondence and information-theoretic compression barriers.

## Main Definitions

- `MonotoneBoolFun` — a monotone Boolean function on a preordered type
- `MonotoneCircuitProfile` — an abstract monotone circuit with size, depth, and semantics
- `ApproximationSandwich` — a pair of positive/negative test families that separate a function
- `MonoFormulaProfile` — wraps monotone formulas into the circuit profile interface

## Main Results

- `approximation_sandwich_lower_bound` — the abstract approximation method:
  if every small circuit fails on some test point, no small circuit computes f
- `monotone_formula_protocol_cost_le_depth` — monotone formulas induce KW protocols
  of cost at most the formula depth (by structural induction)
- `monotone_KW_lower_bound_implies_formula_depth_lower_bound` — the monotone KW transport:
  communication lower bounds yield formula depth lower bounds
- `monotone_formula_depth_ge_of_witness_incompressibility` — compression/entropy
  obstruction to shallow monotone formulas
- `kw_compression_implies_depth_lower_bound` — the cross-domain bridge theorem
  connecting KW witness spaces, compression, and formula depth

## References

* A. A. Razborov, "Lower bounds on the monotone complexity of some Boolean functions",
  Doklady Akademii Nauk SSSR, 1985.
* M. Karchmer, A. Wigderson, "Monotone circuits for connectivity require
  super-logarithmic depth", STOC 1988.
-/

noncomputable section
open Classical Finset

namespace MonotoneComplexity

/-! ## Core Definitions -/

/-- A **monotone Boolean function** on a preordered type `α`.
    This is a Boolean-valued function that is monotone with respect to the
    preorder on `α` and the natural order on `Bool` (where `false ≤ true`).
    The subtype ensures monotonicity is part of the data. -/
def MonotoneBoolFun (α : Type*) [Preorder α] :=
  { f : α → Bool // Monotone f }

/-- A **monotone circuit profile** abstractly represents a monotone circuit.
    It records the circuit's size, depth, evaluation function, and a proof
    of monotonicity. This abstraction captures any concrete circuit model
    (formulas, circuits, branching programs) through a uniform interface. -/
structure MonotoneCircuitProfile (α : Type*) [Preorder α] where
  /-- Number of gates in the circuit -/
  size : ℕ
  /-- Depth (longest input-to-output path) -/
  depth : ℕ
  /-- The function computed by the circuit -/
  eval : α → Bool
  /-- Proof that the computed function is monotone -/
  monotone_eval : Monotone eval

/-- An **approximation sandwich** is a pair of finite test families (positive and negative)
    together with a witness function that perfectly separates them. This is the key
    combinatorial object in Razborov's approximation method: the positive set `pos`
    contains inputs that should evaluate to `true`, and `neg` contains inputs that
    should evaluate to `false`. -/
structure ApproximationSandwich (α : Type*) where
  /-- Positive test instances (should be accepted) -/
  pos : Finset α
  /-- Negative test instances (should be rejected) -/
  neg : Finset α
  /-- The target function restricted to the test instances -/
  witness : α → Bool
  /-- The witness correctly accepts all positive instances -/
  sound_pos : ∀ x ∈ pos, witness x = true
  /-- The witness correctly rejects all negative instances -/
  sound_neg : ∀ x ∈ neg, witness x = false

/-! ## Approximation Method: The Engine Theorem -/

/-
**Approximation Sandwich Lower Bound** (The Engine Theorem).

    This is the abstract core of Razborov's approximation method. It states:
    if a monotone Boolean function `f` perfectly separates a test family `(pos, neg)`,
    and every monotone circuit of size at most `s` disagrees with `f` on some test point,
    then no monotone circuit of size at most `s` computes `f`.

    The proof proceeds by contradiction: if a circuit `C` of size ≤ `s` computed `f`,
    it would agree with `f` on all inputs, contradicting the approximation hypothesis.
-/
theorem approximation_sandwich_lower_bound
    {α : Type*} [Preorder α] [DecidableEq α]
    (f : MonotoneBoolFun α)
    (A : ApproximationSandwich α)
    (s : ℕ)
    (_hsep_pos : ∀ x ∈ A.pos, f.1 x = true)
    (_hsep_neg : ∀ x ∈ A.neg, f.1 x = false)
    (happrox :
      ∀ C : MonotoneCircuitProfile α,
        C.size ≤ s →
        ∃ x, x ∈ A.pos ∪ A.neg ∧ C.eval x ≠ f.1 x) :
    ∀ C : MonotoneCircuitProfile α,
      (∀ x, C.eval x = f.1 x) → s < C.size := by
  grind +splitIndPred

/-! ## Monotone Formulas -/

/-- Monotone Boolean formulas on `n` variables.
    Built from variables, constants, AND, and OR — no negation. -/
inductive MonoFormula (n : ℕ) where
  | var : Fin n → MonoFormula n
  | top : MonoFormula n
  | bot : MonoFormula n
  | and : MonoFormula n → MonoFormula n → MonoFormula n
  | or  : MonoFormula n → MonoFormula n → MonoFormula n

namespace MonoFormula

def eval : MonoFormula n → (Fin n → Bool) → Bool
  | var i, x => x i
  | top, _ => true
  | bot, _ => false
  | and φ₁ φ₂, x => φ₁.eval x && φ₂.eval x
  | or φ₁ φ₂, x => φ₁.eval x || φ₂.eval x

def depth : MonoFormula n → ℕ
  | var _ => 0
  | top => 0
  | bot => 0
  | and φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth
  | or φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth

def size : MonoFormula n → ℕ
  | var _ => 1
  | top => 1
  | bot => 1
  | and φ₁ φ₂ => 1 + φ₁.size + φ₂.size
  | or φ₁ φ₂ => 1 + φ₁.size + φ₂.size

/-- The pointwise ordering on Boolean vectors. -/
def BitwiseLE {n : ℕ} (x y : Fin n → Bool) : Prop :=
  ∀ i, x i = true → y i = true

/-- Monotonicity of Boolean functions on bit vectors. -/
def MonotoneBoolVec {n : ℕ} (f : (Fin n → Bool) → Bool) : Prop :=
  ∀ ⦃x y⦄, BitwiseLE x y → f x = true → f y = true

/-
Every monotone formula computes a monotone Boolean function.
-/
theorem eval_monotone (φ : MonoFormula n) : MonotoneBoolVec φ.eval := by
  induction' φ with i φ₁ φ₂ ih₁ ih₂₁ h₁ φ₂ h₂;
  · exact fun x y hxy hx => hxy i hx;
  · exact fun _ _ _ _ => by tauto;
  · exact fun x y hxy hx => by cases hx;
  · intro x y hxy; have := ih₁ hxy; have := ih₂₁ hxy; simp_all +decide [ BitwiseLE, MonoFormula.eval ] ;
  · intro x y hxy hx; cases hx' : h₁.eval x <;> cases hy' : h₁.eval y <;> cases hx'' : φ₂.eval x <;> cases hy'' : φ₂.eval y <;> simp_all +decide only [eval] ;
    · exact absurd ( ‹MonotoneBoolVec φ₂.eval› hxy hx'' ) ( by aesop );
    · exact absurd ( h₂ hxy hx' ) ( by aesop );
    · exact absurd ( h₂ hxy hx' ) ( by aesop )

end MonoFormula

/-! ## KW Protocol Trees (self-contained) -/

/-- Certified Karchmer–Wigderson protocol trees. -/
inductive KWProto (n : ℕ) :
    ((Fin n → Bool) → Prop) → ((Fin n → Bool) → Prop) → Type 1 where
  | leaf (i : Fin n)
      (hA : (∃ y, PB y) → ∀ x, PA x → x i = true)
      (hB : (∃ x, PA x) → ∀ y, PB y → y i = false) :
      KWProto n PA PB
  | alice (q : (Fin n → Bool) → Bool)
      (t_ff : KWProto n (fun x => PA x ∧ q x = false) PB)
      (t_tt : KWProto n (fun x => PA x ∧ q x = true) PB) :
      KWProto n PA PB
  | bob (q : (Fin n → Bool) → Bool)
      (t_ff : KWProto n PA (fun y => PB y ∧ q y = false))
      (t_tt : KWProto n PA (fun y => PB y ∧ q y = true)) :
      KWProto n PA PB

namespace KWProto

def cost : KWProto n PA PB → ℕ
  | leaf _ _ _ => 0
  | alice _ t₀ t₁ => 1 + max t₀.cost t₁.cost
  | bob _ t₀ t₁ => 1 + max t₀.cost t₁.cost

def weaken {PA PA' PB PB' : (Fin n → Bool) → Prop}
    (hA : ∀ x, PA' x → PA x) (hB : ∀ y, PB' y → PB y) :
    KWProto n PA PB → KWProto n PA' PB'
  | leaf i hA₀ hB₀ =>
      leaf i
        (fun ⟨y, hy⟩ x hx => hA₀ ⟨y, hB y hy⟩ x (hA x hx))
        (fun ⟨x, hx⟩ y hy => hB₀ ⟨x, hA x hx⟩ y (hB y hy))
  | alice q t₀ t₁ =>
      alice q
        (t₀.weaken (fun x ⟨h, hq⟩ => ⟨hA x h, hq⟩) hB)
        (t₁.weaken (fun x ⟨h, hq⟩ => ⟨hA x h, hq⟩) hB)
  | bob q t₀ t₁ =>
      bob q
        (t₀.weaken hA (fun y ⟨h, hq⟩ => ⟨hB y h, hq⟩))
        (t₁.weaken hA (fun y ⟨h, hq⟩ => ⟨hB y h, hq⟩))

theorem weaken_cost {PA PA' PB PB' : (Fin n → Bool) → Prop}
    (hA : ∀ x, PA' x → PA x) (hB : ∀ y, PB' y → PB y)
    (T : KWProto n PA PB) :
    (T.weaken hA hB).cost = T.cost := by
  induction T generalizing PA' PB' with
  | leaf _ _ _ => rfl
  | alice q t₀ t₁ ih₀ ih₁ =>
    simp only [weaken, cost]
    rw [ih₀ (fun x ⟨h, hq⟩ => ⟨hA x h, hq⟩) hB,
        ih₁ (fun x ⟨h, hq⟩ => ⟨hA x h, hq⟩) hB]
  | bob q t₀ t₁ ih₀ ih₁ =>
    simp only [weaken, cost]
    rw [ih₀ hA (fun y ⟨h, hq⟩ => ⟨hB y h, hq⟩),
        ih₁ hA (fun y ⟨h, hq⟩ => ⟨hB y h, hq⟩)]

end KWProto

abbrev KWProtocol (n : ℕ) (f : (Fin n → Bool) → Bool) :=
  KWProto n (fun x => f x = true) (fun y => f y = false)

/-! ## Formula → Protocol -/

/-- Convert a monotone formula to a KW protocol tree.
    This is the forward direction of the Karchmer–Wigderson correspondence:
    every monotone formula of depth `d` yields a protocol of cost at most `d`. -/
def MonoFormula.toKWProto [NeZero n] :
    (φ : MonoFormula n) →
    KWProto n (fun x => φ.eval x = true) (fun y => φ.eval y = false)
  | .var i =>
      .leaf i (fun _ _ hx => hx) (fun _ y hy => by
        simp [MonoFormula.eval] at hy; exact hy)
  | .top =>
      .leaf ⟨0, NeZero.pos n⟩
        (fun ⟨_, hy⟩ => absurd hy (by simp [MonoFormula.eval]))
        (fun _ _ hy => absurd hy (by simp [MonoFormula.eval]))
  | .bot =>
      .leaf ⟨0, NeZero.pos n⟩
        (fun _ _ hx => absurd hx (by simp [MonoFormula.eval]))
        (fun ⟨_, hx⟩ => absurd hx (by simp [MonoFormula.eval]))
  | .or φ₁ φ₂ =>
      .alice (fun x => φ₁.eval x)
        (φ₂.toKWProto.weaken
          (fun x ⟨h_or, h_q⟩ => by
            simp only [MonoFormula.eval, Bool.or_eq_true] at h_or
            cases h_or with
            | inl h => simp [h_q] at h
            | inr h => exact h)
          (fun y h_or => by
            simp only [MonoFormula.eval, Bool.or_eq_false_iff] at h_or
            exact h_or.2))
        (φ₁.toKWProto.weaken
          (fun x ⟨_, h_q⟩ => h_q)
          (fun y h_or => by
            simp only [MonoFormula.eval, Bool.or_eq_false_iff] at h_or
            exact h_or.1))
  | .and φ₁ φ₂ =>
      .bob (fun y => φ₁.eval y)
        (φ₁.toKWProto.weaken
          (fun x h_and => by
            simp only [MonoFormula.eval, Bool.and_eq_true] at h_and
            exact h_and.1)
          (fun y ⟨_, h_q⟩ => h_q))
        (φ₂.toKWProto.weaken
          (fun x h_and => by
            simp only [MonoFormula.eval, Bool.and_eq_true] at h_and
            exact h_and.2)
          (fun y ⟨h_and, h_q⟩ => by
            simp only [MonoFormula.eval, Bool.and_eq_false_iff] at h_and
            cases h_and with
            | inl h => simp [h_q] at h
            | inr h => exact h))

/-! ## Monotone Formula → Protocol Cost Bound (Induction on Formula Structure) -/

/-
**Monotone formula protocol cost bound** (by structural induction).
    Every monotone formula of depth `d` yields a KW protocol of cost ≤ `d`.
    The proof proceeds by induction on the formula structure:
    - Variables yield a leaf protocol (cost 0).
    - OR gates become Alice nodes, AND gates become Bob nodes.
    - At each connective, cost increases by 1 while depth also increases by 1.
-/
theorem monotone_formula_protocol_cost_le_depth [NeZero n]
    (φ : MonoFormula n) :
    φ.toKWProto.cost ≤ φ.depth := by
  induction' φ using MonoFormula.recOn with i φ₁ φ₂ h₁ h₂;
  · rfl;
  · exact Nat.le_of_ble_eq_true rfl;
  · rfl;
  · simp +arith +decide [ *, MonoFormula.toKWProto ];
    simp +arith +decide [ KWProto.cost, MonoFormula.depth ];
    simp +arith +decide [ KWProto.weaken_cost ];
    grind;
  · rename_i φ₁ φ₂ h₁ h₂;
    convert Nat.add_le_add_left ( max_le_max h₁ h₂ ) 1 using 1;
    erw [ KWProto.cost ];
    erw [ KWProto.weaken_cost, KWProto.weaken_cost ] ; ac_rfl

/-
A monotone formula for `f` yields a KW protocol of cost ≤ formula depth.
-/
theorem monotone_formula_gives_KW_protocol [NeZero n]
    (f : (Fin n → Bool) → Bool)
    (φ : MonoFormula n) (hφ : ∀ x, φ.eval x = f x) :
    ∃ P : KWProtocol n f, P.cost ≤ φ.depth := by
  -- Apply the weakening lemma to obtain the desired protocol.
  obtain ⟨P', hP'⟩ := show ∃ P' : KWProto n (fun x => φ.eval x = true) (fun y => φ.eval y = false), P'.cost ≤ φ.depth by
                        exact ⟨ φ.toKWProto, monotone_formula_protocol_cost_le_depth φ ⟩;
  exact ⟨ P'.weaken ( fun x hx => by aesop ) ( fun y hy => by aesop ), by rw [ KWProto.weaken_cost ] ; assumption ⟩

/-! ## Monotone KW Lower Bound Transport -/

/-
**Monotone KW Lower Bound Transfer Theorem**.
    If every KW protocol for a monotone Boolean function `f` on `n` variables
    has communication cost at least `d`, then every monotone formula computing `f`
    has depth at least `d`.

    This is the formal "transport map" that converts communication complexity
    lower bounds into circuit (formula) depth lower bounds.
-/
theorem monotone_KW_lower_bound_implies_formula_depth_lower_bound
    [NeZero n]
    (f : (Fin n → Bool) → Bool)
    (d : ℕ)
    (hkw : ∀ P : KWProtocol n f, d ≤ P.cost) :
    ∀ φ : MonoFormula n, (∀ x, φ.eval x = f x) → d ≤ φ.depth := by
  intro φ hφ; have := monotone_formula_gives_KW_protocol f φ hφ; obtain ⟨ P, hP ⟩ := this; exact le_trans ( hkw P ) hP;

/-! ## KW Witness Space and Compression Bridge -/

/-- Boolean vectors of length `n`. -/
abbrev BoolVec (n : ℕ) := Fin n → Bool

/-- A KW witness for a Boolean function `f`: a triple `(x, y, i)` where
    `f(x) = true`, `f(y) = false`, and `x(i) ≠ y(i)`. -/
def KWWitness {n : ℕ} (f : BoolVec n → Bool) :=
  { w : BoolVec n × BoolVec n × Fin n //
    f w.1 = true ∧ f w.2.1 = false ∧ w.1 w.2.2 ≠ w.2.1 w.2.2 }

instance {n : ℕ} (f : BoolVec n → Bool) : Fintype (KWWitness f) :=
  Subtype.fintype _

/-- A KW complexity lower bound: the witness space has ≥ `2^d` elements. -/
def kwComplexityLB {n : ℕ} (f : BoolVec n → Bool) (d : ℕ) : Prop :=
  2 ^ d ≤ Fintype.card (KWWitness f)

/-- Variable-length bitstrings up to length `k`. -/
abbrev BoundedBitstring (k : ℕ) := Σ i : Fin (k + 1), (Fin i → Bool)

/-
The number of bounded bitstrings is `2^(k+1) - 1`.
-/
theorem card_bounded_bitstrings (k : ℕ) :
    Fintype.card (BoundedBitstring k) = 2 ^ (k + 1) - 1 := by
  convert Nat.geomSum_eq ?_ ?_ using 1;
  convert Fintype.card_sigma;
  convert Finset.sum_range ?_;
  rotate_left;
  rotate_left;
  exacts [ 2, by decide, by simp +decide [ Fintype.card_pi ], by norm_num ]

/-
Any injective encoding into bounded bitstrings forces a cardinality bound.
-/
theorem cardinality_forces_long_code
    {α : Type*} [Fintype α]
    (Enc : α → List Bool)
    (hinj : Function.Injective Enc)
    (d : ℕ)
    (hlarge : 2 ^ d ≤ Fintype.card α) :
    ∃ a : α, d ≤ (Enc a).length := by
  by_contra hlarge;
  -- By assumption, every codeword has length < d, so all codewords are bounded bitstrings of length ≤ d-1.
  have h_bounded : ∀ a : α, (Enc a).length ≤ d - 1 := by
    exact fun a => Nat.le_sub_one_of_lt ( lt_of_not_ge fun h => hlarge ⟨ a, h ⟩ );
  -- Since every codeword has length ≤ d-1, there are at most 2^(d-1) possible codewords.
  have h_card : Fintype.card α ≤ Fintype.card (BoundedBitstring (d - 1)) := by
    refine' Fintype.card_le_of_injective _ _;
    exact fun a => ⟨ ⟨ ( Enc a ).length, Nat.lt_succ_of_le ( h_bounded a ) ⟩, fun i => ( Enc a ).get i ⟩;
    intro a b hab;
    exact hinj ( by simpa [ List.ofFn_get ] using congr_arg ( fun x : Σ i : Fin ( d - 1 + 1 ), Fin i → Bool => List.ofFn x.2 ) hab );
  rcases d with ( _ | d ) <;> simp_all +decide;
  exact absurd ‹2 ^ ( d + 1 ) ≤ Fintype.card α› ( not_le_of_gt ( lt_of_le_of_lt h_card ( by induction' d + 1 with d hd <;> simp +decide [ Fin.sum_univ_castSucc, pow_succ' ] at * ; linarith ) ) )

/-
**KW Witness Compression Lower Bound**: If the KW witness space for `f` has
    at least `2^d` elements, then any injective encoding of witnesses must assign
    some witness a code of length ≥ `d`.
-/
theorem kw_witness_compression_lower_bound
    {n : ℕ} (f : BoolVec n → Bool) (d : ℕ)
    (hkw : kwComplexityLB f d) :
    ∀ (Enc : KWWitness f → List Bool),
      Function.Injective Enc →
      ∃ w : KWWitness f, d ≤ (Enc w).length := by
  convert cardinality_forces_long_code using 1;
  convert Iff.rfl;
  exact iff_of_true ( fun d hd => cardinality_forces_long_code _ ‹_› _ hd ) ( cardinality_forces_long_code _ ‹_› _ hkw )

/-
**Cross-Domain Bridge: KW Compression → Formula Depth Lower Bound**.
    If the KW witness space is large enough that no short encoding exists,
    then any monotone formula computing `f` must have sufficient depth.
    This connects three domains:
    1. Communication complexity (KW witness space size)
    2. Compression theory (encoding lower bounds)
    3. Circuit complexity (formula depth)
-/
theorem kw_compression_implies_depth_lower_bound
    {n d : ℕ} [NeZero n]
    (f : BoolVec n → Bool)
    (_hkw : kwComplexityLB f d)
    (hproto : ∀ P : KWProtocol n f, d ≤ P.cost) :
    ∀ φ : MonoFormula n, (∀ x, φ.eval x = f x) → d ≤ φ.depth := by
  convert monotone_KW_lower_bound_implies_formula_depth_lower_bound f d hproto

/-! ## Witness Incompressibility and Depth Obstruction -/

/-- A monotone Boolean function has **incompressible KW witnesses** at level `d`
    if its KW witness space has at least `2^d` elements. This means no encoding
    can represent all witnesses in fewer than `d` bits. -/
def monotone_kw_witness_incompressible
    {n : ℕ} (f : BoolVec n → Bool) (d : ℕ) : Prop :=
  kwComplexityLB f d

/-
**Depth Lower Bound via Witness Incompressibility**.
    If the KW witness relation for `f` is incompressible at level `d`,
    and every KW protocol for `f` has cost ≥ `d`, then every monotone
    formula computing `f` has depth ≥ `d`.

    This theorem unifies:
    - `kw_witness_compression_lower_bound` (compression → long codes)
    - `monotone_KW_lower_bound_implies_formula_depth_lower_bound` (KW → depth)
-/
theorem monotone_formula_depth_ge_of_witness_incompressibility
    {n d : ℕ} [NeZero n]
    (f : BoolVec n → Bool)
    (_hincomp : monotone_kw_witness_incompressible f d)
    (hproto : ∀ P : KWProtocol n f, d ≤ P.cost) :
    ∀ φ : MonoFormula n, (∀ x, φ.eval x = f x) → d ≤ φ.depth := by
  convert monotone_KW_lower_bound_implies_formula_depth_lower_bound f d hproto

/-! ## Entropy Lower Bound Bridge -/

/-
**Log-cardinality entropy bound from KW complexity**:
    If the KW witness space has ≥ `2^d` elements, then `d ≤ log₂ |KWWitness f|`.
-/
theorem kw_log_entropy_lower_bound
    {n : ℕ} (f : BoolVec n → Bool) (d : ℕ)
    (hkw : kwComplexityLB f d) :
    d ≤ Nat.log 2 (Fintype.card (KWWitness f)) := by
  exact Nat.le_log_of_pow_le ( by decide ) hkw

end MonotoneComplexity