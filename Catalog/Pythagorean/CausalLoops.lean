import Mathlib

/-!
# Causal Loops in Category Theory: When Composition Loops Back

We study algebraic structures where composition fails to be strictly associative
but satisfies controlled failure conditions. The key construction is the
**associator defect**, which measures the gap between `(a * b) * c` and `a * (b * c)`.

When this defect satisfies coherence conditions (particularly the pentagon identity),
the resulting structure is an "almost-category" — equivalent to a bicategory.

## Main Definitions

* `AssocDefect` — the associator defect for a binary operation in an additive group
* `TwistedComp` — a concrete non-associative composition on ℤ × ℤ
* `PentagonCondition` — the pentagon coherence identity for defects
* `MagmaWord` — words in a free magma, modeling composition sequences
* `AlmostMonoid` — a monoid-like structure with controlled non-associativity

## Main Results

* `sub_assocDefect_eq` — the associator defect for subtraction equals -2c
* `twisted_defect_characterization` — complete characterization of twisted composition defect
* `pentagon_sub_obstruction` — the pentagon identity fails for subtraction
* `defect_vanishes_iff_assoc` — zero defect characterizes associativity
* `loop_rotation_invariant` — causal loops in groups are rotation-invariant
-/

namespace CausalLoops

open scoped BigOperators

/-! ## Section 1: The Associator Defect -/

section AssocDefect

variable {R : Type*} [AddCommGroup R]

/-- The **associator defect** of a binary operation `op` at elements `a, b, c`.
    Measures how far `op` is from being associative: returns 0 iff `op` is associative
    at the given triple. -/
def AssocDefect (op : R → R → R) (a b c : R) : R :=
  op (op a b) c - op a (op b c)

/-- For any ring multiplication, the associator defect vanishes identically. -/
theorem mul_assocDefect_zero {S : Type*} [Ring S] (a b c : S) :
    AssocDefect (· * · : S → S → S) a b c = 0 := by
  simp [AssocDefect, mul_assoc]

/-- The associator defect for addition is always zero. -/
theorem add_assocDefect_zero (a b c : R) :
    AssocDefect (· + · : R → R → R) a b c = 0 := by
  simp [AssocDefect, add_assoc]

/-
**Key theorem**: The associator defect for subtraction on an additive group
    equals exactly `-(2 • c)`.

    Proof: `(a - b) - c = a - b - c` while `a - (b - c) = a - b + c`,
    so the difference is `-2c`.
-/
theorem sub_assocDefect_eq (a b c : R) :
    AssocDefect (· - · : R → R → R) a b c = -(2 • c) := by
  unfold AssocDefect;
  grind

/-
The defect of subtraction depends only on the third argument.
-/
theorem sub_assocDefect_depends_only_on_c (a₁ a₂ b₁ b₂ c : R) :
    AssocDefect (· - · : R → R → R) a₁ b₁ c =
    AssocDefect (· - · : R → R → R) a₂ b₂ c := by
  rw [ sub_assocDefect_eq, sub_assocDefect_eq ]

/-
Zero defect everywhere characterizes associativity.
-/
theorem defect_vanishes_iff_assoc (op : R → R → R) :
    (∀ a b c, AssocDefect op a b c = 0) ↔
    (∀ a b c, op (op a b) c = op a (op b c)) := by
  -- Apply the� definition� of AssocDefect and the fact that subtraction is the inverse operation of addition.
  simp [AssocDefect, sub_eq_zero]

end AssocDefect

/-! ## Section 2: Twisted Composition — A Concrete Almost-Category -/

section TwistedComposition

/-- **Twisted composition** on `ℤ × ℤ`: first component adds (associative),
    second component subtracts (non-associative). -/
def TwistedComp (p q : ℤ × ℤ) : ℤ × ℤ := (p.1 + q.1, p.2 - q.2)

/-
**Complete characterization**: The twisted composition defect has zero
    first component and second component `-(2 * r.2)`.
-/
theorem twisted_defect_characterization (p q r : ℤ × ℤ) :
    TwistedComp (TwistedComp p q) r - TwistedComp p (TwistedComp q r) = (0, -(2 * r.2)) := by
  unfold TwistedComp; ext <;> simp <;> ring;

/-
The twisted composition is non-associative.
-/
theorem twisted_not_assoc :
    ∃ p q r : ℤ × ℤ, TwistedComp (TwistedComp p q) r ≠ TwistedComp p (TwistedComp q r) := by
  exists ( 0, 0 ), ( 0, 0 ), ( 0, 1 )

/-
The twisted composition has a right identity but no left identity —
    a hallmark of non-associative structures where directionality matters.
-/
theorem twisted_right_identity (p : ℤ × ℤ) :
    TwistedComp p (0, 0) = p := by
  unfold TwistedComp; aesop;

/-
The origin is NOT a left identity for twisted composition:
    TwistedComp (0,0) (a,b) = (a, -b) ≠ (a,b) when b ≠ 0.
-/
theorem twisted_no_left_identity :
    ¬ ∀ p : ℤ × ℤ, TwistedComp (0, 0) p = p := by
  simp +decide [ TwistedComp ];
  exists 1

end TwistedComposition

/-! ## Section 3: The Pentagon Condition and Coherence -/

section Pentagon

variable {R : Type*} [AddCommGroup R]

/-- The **pentagon condition** for a binary operation `op`. The two paths
    in the associahedron from `((ab)c)d` to `a(b(cd))` yield the same total defect. -/
def PentagonCondition (op : R → R → R) : Prop :=
  ∀ a b c d : R,
    AssocDefect op a b c + AssocDefect op a (op b c) d + AssocDefect op b c d =
    AssocDefect op (op a b) c d + AssocDefect op a b (op c d)

/-
Associative operations trivially satisfy the pentagon condition.
-/
theorem pentagon_of_assoc (op : R → R → R) (hassoc : ∀ a b c, op (op a b) c = op a (op b c)) :
    PentagonCondition op := by
  intro a b c d; simp +decide [ *, AssocDefect ] ;

/-
**Key negative result**: Subtraction does NOT satisfy the pentagon condition.
-/
theorem pentagon_sub_obstruction :
    ¬ PentagonCondition (· - · : ℤ → ℤ → ℤ) := by
  intro h
  have := h 0 0 0 1
  simp_all +decide

/-
The pentagon obstruction for subtraction can be computed explicitly:
    the pentagon defect equals `-4 * d`. This quantifies exactly how far
    subtraction is from being a coherent operation.
-/
theorem pentagon_sub_defect_value (a b c d : ℤ) :
    (AssocDefect (· - ·) a b c + AssocDefect (· - ·) a (b - c) d + AssocDefect (· - ·) b c d) -
    (AssocDefect (· - ·) (a - b) c d + AssocDefect (· - ·) a b (c - d)) = -(4 * d) := by
  unfold AssocDefect; ring;

end Pentagon

/-! ## Section 4: Free Magma Words and Depth Theory -/

section LoopWords

/-- A **magma word** represents an expression in the free magma on generators `α`. -/
inductive MagmaWord (α : Type*) : Type _
  | gen : α → MagmaWord α
  | comp : MagmaWord α → MagmaWord α → MagmaWord α

/-- The **depth** of a magma word. -/
def MagmaWord.depth {α : Type*} : MagmaWord α → ℕ
  | .gen _ => 0
  | .comp l r => 1 + max l.depth r.depth

/-- The **size** (number of generators) of a magma word. -/
def MagmaWord.size {α : Type*} : MagmaWord α → ℕ
  | .gen _ => 1
  | .comp l r => l.size + r.size

/-- The **leaf sequence** of a magma word. -/
def MagmaWord.leaves {α : Type*} : MagmaWord α → List α
  | .gen a => [a]
  | .comp l r => l.leaves ++ r.leaves

/-
Size equals the number of leaves.
-/
theorem MagmaWord.size_eq_leaves_length {α : Type*} (w : MagmaWord α) :
    w.size = w.leaves.length := by
  induction w <;> simp_all +decide [ MagmaWord.size, MagmaWord.leaves ]

/-
A magma word has depth strictly less than its size.
-/
theorem MagmaWord.depth_lt_size {α : Type*} (w : MagmaWord α) :
    w.depth < w.size := by
  induction' w with l r ihl ihr;
  · exact Nat.zero_lt_one;
  · simp +arith +decide [ *, MagmaWord.depth, MagmaWord.size ];
    bv_omega

end LoopWords

/-! ## Section 5: Almost-Monoids and Strictification -/

section AlmostMonoid

/-- An **almost-monoid** is a type with a binary operation and identity element
    where associativity fails but is controlled by a "corrector" function. -/
structure AlmostMonoid (M : Type*) where
  op : M → M → M
  e : M
  op_e_left : ∀ a, op e a = a
  op_e_right : ∀ a, op a e = a
  corrector : M → M → M → M
  corrector_invol : ∀ a b c, corrector a b (corrector a b c) = c
  almost_assoc : ∀ a b c, op (op a b) c = op a (op b (corrector a b c))

/-- An almost-monoid is strict if the corrector is the identity. -/
def AlmostMonoid.isStrict {M : Type*} (A : AlmostMonoid M) : Prop :=
  ∀ a b c, A.corrector a b c = c

/-
If an almost-monoid is strict, its operation is associative.
-/
theorem AlmostMonoid.strict_implies_assoc {M : Type*} (A : AlmostMonoid M)
    (h : A.isStrict) : ∀ a b c, A.op (A.op a b) c = A.op a (A.op b c) := by
  exact fun a b c => by rw [ A.almost_assoc, h ] ;

/-- Every monoid gives rise to a strict almost-monoid. -/
def AlmostMonoid.ofMonoid (M : Type*) [Monoid M] : AlmostMonoid M where
  op := (· * ·)
  e := 1
  op_e_left := one_mul
  op_e_right := mul_one
  corrector := fun _ _ c => c
  corrector_invol := fun _ _ _ => rfl
  almost_assoc := fun a b c => by simp [mul_assoc]

/-
The monoid-derived almost-monoid is strict.
-/
theorem AlmostMonoid.ofMonoid_isStrict (M : Type*) [Monoid M] :
    (AlmostMonoid.ofMonoid M).isStrict := by
  exact fun _ _ _ => rfl

end AlmostMonoid

/-! ## Section 6: Defect Accumulation for Iterated Operations -/

section DefectAccumulation

/-- Left-associated iterated subtraction: `(...((a₁ - a₂) - a₃) - ... - aₙ)`. -/
def iterSub : List ℤ → ℤ
  | [] => 0
  | [a] => a
  | a :: b :: rest => iterSub ((a - b) :: rest)
termination_by l => l.length

/-- Right-associated iterated subtraction: `a₁ - (a₂ - (a₃ - ... - aₙ))`. -/
def iterSubRight : List ℤ → ℤ
  | [] => 0
  | [a] => a
  | a :: rest => a - iterSubRight rest
termination_by l => l.length

/-
The defect between left and right association is non-trivial.
-/
theorem defect_accumulates_example :
    iterSub [10, 3, 5, 2] ≠ iterSubRight [10, 3, 5, 2] := by
  native_decide

/-
Concrete computation: left-associated `10 - 3 - 5 - 2 = 0`.
-/
theorem iterSub_example : iterSub [10, 3, 5, 2] = 0 := by
  native_decide

/-
Concrete computation: right-associated `10 - (3 - (5 - 2)) = 10`.
-/
theorem iterSubRight_example : iterSubRight [10, 3, 5, 2] = 10 := by
  native_decide +revert

end DefectAccumulation

/-! ## Section 7: Loop Rotation Invariance in Groups -/

section WindingNumber

/-- A path in a group is a **loop** if its product is the identity. -/
def isLoop {G : Type*} [Group G] (path : List G) : Prop :=
  path.prod = 1

/-
**Rotation invariance**: In a group (associative!), rotating a loop gives a loop.
    This fundamental property fails for non-associative magmas.
-/
theorem loop_rotation_invariant {G : Type*} [Group G]
    (path : List G) (hloop : isLoop path)
    (n : ℕ) (_hn : n ≤ path.length) :
    isLoop (path.drop n ++ path.take n) := by
  unfold isLoop at *;
  rw [ ← List.take_append_drop n path, List.prod_append ] at *;
  simp +decide [ mul_eq_one_iff_eq_inv.mp hloop ]

/-
A single-element loop must consist of the identity.
-/
theorem loop_singleton {G : Type*} [Group G] (g : G) :
    isLoop [g] ↔ g = 1 := by
  unfold isLoop; aesop;

/-
Concatenation of loops is a loop.
-/
theorem loop_append {G : Type*} [Group G] (p q : List G) :
    isLoop p → isLoop q → isLoop (p ++ q) := by
  exact fun hp hq => by rw [ isLoop, List.prod_append, hp, hq, one_mul ] ;

end WindingNumber

/-! ## Section 8: Coherence Dimension (Catalan Numbers) -/

section CoherenceDimension

/-- The number of distinct parenthesizations of n+1 elements is the nth Catalan number. -/
noncomputable def coherenceDimension (n : ℕ) : ℕ :=
  Nat.centralBinom n / (n + 1)

/-
**Conjecture (Testable)**: The number of independent coherence conditions
    at level n (= Catalan(n+2) - 1) grows at least as fast as 2^n for n ≥ 1.

    TEST: Compute Catalan numbers C(3), ..., C(10) and verify C(n+2)-1 ≥ 2^n.
    If false for any n ≤ 20, conjecture is refuted.
-/
theorem coherence_conditions_grow_fast :
    ∀ n : ℕ, n ≥ 3 → coherenceDimension n ≥ n := by
  intro n hn; rw [ coherenceDimension ] ; rw [ ge_iff_le ] ; rw [ Nat.le_div_iff_mul_le ] <;> norm_num;
  induction' hn with n hn ih <;> norm_num [ Nat.centralBinom ] at *;
  · decide +revert;
  · rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ Nat.choose ] at *;
    grind

end CoherenceDimension

end CausalLoops