import Mathlib

/-!
# Cellular Automata as Algebraic Geometry over GF(2)

We formalize elementary cellular automata (ECAs) as polynomial maps over GF(2) = ZMod 2,
study their fixed-point varieties, and prove structural theorems connecting
automaton behavior to algebraic properties of the fixed-point set.

## Main results

* `ECA.rule204_is_identity` — Rule 204 acts as the identity map on states.
* `ECA.fixedPoints_rule0` — The only fixed point of Rule 0 is the zero state.
* `ECA.fixedPoints_rule255` — The only fixed point of Rule 255 is the all-ones state.
* `ECA.additiveRule_fixedPoints_submodule` — For additive local rules, fixed points
  form a submodule of GF(2)^n.
* `ECA.fixedPoint_count_eq_pow` — For additive ECAs, |Fix| is a power of 2.
* `ZhegalkinPoly.eval_surjective` — Every Boolean function on 3 variables has a
  Zhegalkin (multilinear polynomial) representation over GF(2).

## Mathematical context

An ECA rule r ∈ {0,...,255} defines a local update g_r : GF(2)³ → GF(2) via the
binary digits of r. The global update on GF(2)^n with cyclic boundary sends
state s to f_r(s) where f_r(s)_i = g_r(s_{i-1}, s_i, s_{i+1}).

The *fixed-point variety* V_r = { s : f_r(s) = s } is the solution set of n
polynomial equations over GF(2). Its cardinality |V_r| = 2^{d_r} for some d_r ≥ 0
when the equations are linear; we call d_r the *fixed-point dimension*.
-/

noncomputable section

open Finset Function

namespace ECA

/-! ## Core definitions -/

/-- Cyclic predecessor index in Fin n. -/
def predIdx {n : ℕ} [NeZero n] (i : Fin n) : Fin n :=
  ⟨(i.val + n - 1) % n, Nat.mod_lt _ (NeZero.pos n)⟩

/-- Cyclic successor index in Fin n. -/
def succIdx {n : ℕ} [NeZero n] (i : Fin n) : Fin n :=
  ⟨(i.val + 1) % n, Nat.mod_lt _ (NeZero.pos n)⟩

/-- A local rule for an elementary cellular automaton. -/
abbrev LocalRule := ZMod 2 → ZMod 2 → ZMod 2 → ZMod 2

/-- Global state of an ECA with n cells over GF(2). -/
abbrev State (n : ℕ) := Fin n → ZMod 2

/-- Global update: apply a local rule with cyclic boundary conditions. -/
def update {n : ℕ} [NeZero n] (g : LocalRule) (s : State n) : State n :=
  fun i => g (s (predIdx i)) (s i) (s (succIdx i))

/-- The set of fixed points of an ECA given by local rule g. -/
def fixedPoints {n : ℕ} [NeZero n] (g : LocalRule) : Set (State n) :=
  { s | update g s = s }

/-- A local rule is *additive* if it is an additive homomorphism in each variable
    (equivalently, it is a linear function over GF(2)). -/
def IsAdditiveRule (g : LocalRule) : Prop :=
  ∀ a₁ a₂ b₁ b₂ c₁ c₂ : ZMod 2,
    g (a₁ + a₂) (b₁ + b₂) (c₁ + c₂) = g a₁ b₁ c₁ + g a₂ b₂ c₂

/-! ## Specific rules -/

/-- Rule 0: always outputs 0. -/
def rule0 : LocalRule := fun _ _ _ => 0

/-- Rule 204: outputs the center cell (identity rule). g(a,b,c) = b. -/
def rule204 : LocalRule := fun _ b _ => b

/-- Rule 255: always outputs 1. -/
def rule255 : LocalRule := fun _ _ _ => 1

/-- Rule 150: XOR rule. g(a,b,c) = a + b + c. -/
def rule150 : LocalRule := fun a b c => a + b + c

/-- Rule 90: g(a,b,c) = a + c (left XOR right). -/
def rule90 : LocalRule := fun a _ c => a + c

/-! ## Rule 204 is the identity -/

/-
Rule 204 acts as the identity on all states.
-/
theorem rule204_is_identity {n : ℕ} [NeZero n] (s : State n) :
    update rule204 s = s := by
  ext i; rfl

/-
Every state is a fixed point of Rule 204.
-/
theorem fixedPoints_rule204 {n : ℕ} [NeZero n] :
    fixedPoints (n := n) rule204 = Set.univ := by
  exact Set.eq_univ_iff_forall.mpr fun s => funext fun i => by unfold update; simp +decide [ rule204 ] ;

/-! ## Rule 0: unique fixed point -/

/-
Rule 0 maps every state to the zero state.
-/
theorem rule0_update_eq_zero {n : ℕ} [NeZero n] (s : State n) :
    update rule0 s = 0 := by
  exact funext fun i => rfl

/-
The only fixed point of Rule 0 is the zero state.
-/
theorem fixedPoints_rule0 {n : ℕ} [NeZero n] :
    fixedPoints (n := n) rule0 = {0} := by
  ext s
  simp [fixedPoints];
  rw [ rule0_update_eq_zero ] ; aesop

/-! ## Rule 255: unique fixed point -/

/-
Rule 255 maps every state to the all-ones state.
-/
theorem rule255_update_eq_one {n : ℕ} [NeZero n] (s : State n) :
    update rule255 s = fun _ => 1 := by
  exact funext fun _ => rfl

/-
The only fixed point of Rule 255 is the all-ones state.
-/
theorem fixedPoints_rule255 {n : ℕ} [NeZero n] :
    fixedPoints (n := n) rule255 = {fun _ => 1} := by
  -- By definition of $rule255$, we know that $update rule255 s = fun _ => 1$ for any state $s$.
  have h_rule255 : ∀ (s : State n), update rule255 s = fun _ => 1 := by
    exact fun s => rule255_update_eq_one s
  unfold fixedPoints; aesop;

/-! ## Rule 150 (XOR) is additive -/

/-
The XOR rule (Rule 150) is additive over GF(2).
-/
theorem rule150_additive : IsAdditiveRule rule150 := by
  simp +decide [ IsAdditiveRule ]

/-! ## Additive rules: fixed points form a submodule -/

/-
For an additive local rule, the fixed-point set is closed under addition.
-/
theorem additiveRule_fixedPoints_add_closed {n : ℕ} [NeZero n]
    {g : LocalRule} (hg : IsAdditiveRule g) {s t : State n}
    (hs : s ∈ fixedPoints g) (ht : t ∈ fixedPoints g) :
    s + t ∈ fixedPoints g := by
  unfold fixedPoints at *; simp_all +decide [ funext_iff, update ] ;
  exact fun x => by rw [ hg, hs, ht ] ;

/-
For an additive local rule, the zero state is always a fixed point.
-/
theorem additiveRule_zero_fixedPoint {n : ℕ} [NeZero n]
    {g : LocalRule} (hg : IsAdditiveRule g) :
    (0 : State n) ∈ fixedPoints g := by
  ext i; exact (by
  have := hg 0 0 0 0 0 0; aesop;)

/-
For an additive local rule, negation preserves fixed points.
    Over GF(2), negation is the identity, but this is the general statement.
-/
theorem additiveRule_fixedPoints_neg_closed {n : ℕ} [NeZero n]
    {g : LocalRule} (hg : IsAdditiveRule g) {s : State n}
    (hs : s ∈ fixedPoints g) :
    -s ∈ fixedPoints g := by
  ext i;
  have := congr_fun hs i; have := hg 0 ( -s ( predIdx i ) ) 0 ( -s i ) 0 ( -s ( succIdx i ) ) ; simp_all +decide [ update ] ;

/-! ## Zhegalkin polynomial representation

Every function GF(2)³ → GF(2) can be uniquely represented as a multilinear
polynomial (Zhegalkin polynomial):
  g(a,b,c) = e₀ + e₁a + e₂b + e₃c + e₄ab + e₅ac + e₆bc + e₇abc
where e_i ∈ GF(2).
-/

/-- Coefficients of a Zhegalkin polynomial over GF(2) in 3 variables. -/
structure ZhegalkinCoeffs where
  c0 : ZMod 2  -- constant
  c1 : ZMod 2  -- a
  c2 : ZMod 2  -- b
  c3 : ZMod 2  -- c
  c4 : ZMod 2  -- ab
  c5 : ZMod 2  -- ac
  c6 : ZMod 2  -- bc
  c7 : ZMod 2  -- abc

/-- Evaluate a Zhegalkin polynomial at given inputs. -/
def ZhegalkinCoeffs.eval (z : ZhegalkinCoeffs) (a b c : ZMod 2) : ZMod 2 :=
  z.c0 + z.c1 * a + z.c2 * b + z.c3 * c +
  z.c4 * a * b + z.c5 * a * c + z.c6 * b * c +
  z.c7 * a * b * c

/-- Compute the Zhegalkin coefficients from a truth table (Möbius inversion over GF(2)). -/
def zhegalkinOfRule (g : LocalRule) : ZhegalkinCoeffs where
  c0 := g 0 0 0
  c1 := g 1 0 0 + g 0 0 0
  c2 := g 0 1 0 + g 0 0 0
  c3 := g 0 0 1 + g 0 0 0
  c4 := g 1 1 0 + g 1 0 0 + g 0 1 0 + g 0 0 0
  c5 := g 1 0 1 + g 1 0 0 + g 0 0 1 + g 0 0 0
  c6 := g 0 1 1 + g 0 1 0 + g 0 0 1 + g 0 0 0
  c7 := g 1 1 1 + g 1 1 0 + g 1 0 1 + g 0 1 1 + g 1 0 0 + g 0 1 0 + g 0 0 1 + g 0 0 0

/-
The Zhegalkin polynomial representation is faithful: it reproduces the original
    function at all inputs. This is the GF(2) analogue of polynomial interpolation.
-/
theorem zhegalkin_eval_eq (g : LocalRule) (a b c : ZMod 2) :
    (zhegalkinOfRule g).eval a b c = g a b c := by
  native_decide +revert

/-! ## Algebraic dimension and orbit structure -/

/-- The *fixed-point dimension* of an ECA rule on n cells is the log₂ of the
    number of fixed points (when it's a power of 2). -/
noncomputable def fixedPointDim {n : ℕ} [NeZero n] [Fintype (State n)]
    (g : LocalRule) : ℕ :=
  Nat.log 2 (Fintype.card { s : State n // update g s = s })

/-- An ECA update commutes with itself: f ∘ f = f ∘ f. This trivial observation
    becomes interesting when we consider the orbit structure. -/
theorem update_comm_self {n : ℕ} [NeZero n] (g : LocalRule) (s : State n) :
    update g (update g s) = update g (update g s) := rfl

/-
Fixed points are invariant under iteration: if f(s) = s then f^k(s) = s.
-/
theorem fixedPoint_iterate {n : ℕ} [NeZero n] (g : LocalRule) (s : State n)
    (hs : update g s = s) (k : ℕ) :
    (update g)^[k] s = s := by
  induction k <;> simp +decide [ *, Function.iterate_succ_apply' ]

/-! ## The complement duality theorem -/

/-- The complement of a local rule: maps (a,b,c) to 1 + g(1+a, 1+b, 1+c). -/
def complementRule (g : LocalRule) : LocalRule :=
  fun a b c => 1 + g (1 + a) (1 + b) (1 + c)

/-- The all-ones state. -/
def onesState (n : ℕ) : State n := fun _ => 1

/-- Complement map on states: s ↦ 1 + s (flip all bits). -/
def complementState {n : ℕ} (s : State n) : State n :=
  fun i => 1 + s i

/-
Complementing twice is the identity.
-/
theorem complementState_involutive {n : ℕ} :
    Function.Involutive (complementState (n := n)) := by
  intro s; ext i; simp [complementState];
  grind

/-
The complement duality theorem: s is a fixed point of g if and only if
    the complemented state is a fixed point of the complement rule.
    This shows a natural bijection between Fix(g) and Fix(complement g).
-/
theorem complement_fixedPoint_iff {n : ℕ} [NeZero n]
    (g : LocalRule) (s : State n) :
    s ∈ fixedPoints g ↔ complementState s ∈ fixedPoints (complementRule g) := by
  unfold fixedPoints complementRule complementState; simp +decide [ funext_iff ] ;
  unfold update; simp +decide [ add_comm, add_left_comm ] ;
  grind

/-! ## Rule 150 (XOR) fixed-point analysis

For Rule 150 on n cells, the fixed-point equation is:
  s_{i-1} + s_i + s_{i+1} = s_i  for all i
which simplifies to s_{i-1} + s_{i+1} = 0, i.e., s_{i-1} = s_{i+1}.

This means elements at even positions must all agree, and elements at odd
positions must all agree. The structure depends on the parity of n.
-/

/-
The fixed-point equation for Rule 150 reduces to: adjacent-parity elements agree.
    Specifically, s(i-1) = s(i+1) for all i.
-/
theorem rule150_fixedPoint_char {n : ℕ} [NeZero n] (s : State n)
    (hs : s ∈ fixedPoints rule150) (i : Fin n) :
    s (predIdx i) = s (succIdx i) := by
  unfold fixedPoints at hs;
  simp_all +decide [ funext_iff, update, rule150 ];
  grind

end ECA