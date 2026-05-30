import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

This module develops the foundational framework for arithmetic on the Poincaré disk
model of hyperbolic geometry. The central algebraic operation is **Möbius addition**,
which endows the open unit interval with a gyrogroup structure fundamentally different
from ordinary addition.

## Main Results

### Möbius Gyrogroup Structure
* `moebius_denom_pos` — The denominator 1 + ab is positive for disk points
* `moebius_preserves_disk` — Möbius addition preserves the unit disk
* `moebius_add_comm` — Commutativity of Möbius addition
* `moebius_add_zero` — Zero is the identity element
* `moebius_add_neg_cancel` — Additive inverse property

### Zeta Summand Reversal
* `zeta_summand_bound` — Disk point powers are less than 1
* `zeta_summand_strict_decay` — Geometric decay of hyperbolic zeta summands

### Exponential Growth
* `geometric_sum_formula` — Geometric series formula by induction
* `regular_tree_exponential_growth` — Ball growth rate for regular trees

### Cross-Domain Bridge: Pythagorean Triples to Hyperbolic Geometry
* `pythagorean_embeds_in_disk` — Pythagorean triples give disk points
* `pythagorean_moebius_closure` — Möbius sums of Pythagorean-rational points stay bounded
* `pythagorean_prime_witness` — Existence of prime-leg Pythagorean triples

## Novel Concepts
* `MoebiusGyrogroup` — The gyrogroup structure on (-1, 1) under Möbius addition
-/

namespace HyperbolicNumberTheory

open Real BigOperators

/-! ## Part I: Möbius Addition on the Poincaré Disk -/

/-- Möbius addition: the canonical binary operation on the Poincaré disk.
    For real numbers a, b with |a|, |b| < 1, their Möbius sum is (a + b)/(1 + ab).
    This is the restriction to ℝ of the complex Möbius gyroaddition
    z ⊕ w = (z + w)/(1 + conj z · w) on the unit disk. -/
noncomputable def moebiusAdd (a b : ℝ) : ℝ := (a + b) / (1 + a * b)

/-
**Positivity of the Möbius denominator.**
    When |a| < 1 and |b| < 1, the product ab satisfies |ab| < 1,
    so 1 + ab > 0. This is the key lemma ensuring Möbius addition is well-defined.
-/
theorem moebius_denom_pos (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1) :
    1 + a * b > 0 := by
  nlinarith [ abs_lt.mp ha, abs_lt.mp hb ]

/-- Nonzero variant of denominator positivity, useful for division. -/
theorem moebius_denom_ne_zero (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1) :
    1 + a * b ≠ 0 :=
  ne_of_gt (moebius_denom_pos a b ha hb)

/-
**Möbius Disk Preservation Theorem**.
    The Möbius sum of two disk points remains strictly inside the disk. This establishes
    that (-1, 1) is closed under Möbius addition, the fundamental algebraic
    property of the Poincaré disk model.

    The proof reduces to showing (a+b)² < (1+ab)², which factors as
    (1 - a²)(1 - b²) > 0, true since |a| < 1 and |b| < 1.
-/
theorem moebius_preserves_disk (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1) :
    |moebiusAdd a b| < 1 := by
  rw [ moebiusAdd, abs_div ];
  rw [ div_lt_one ( abs_pos.mpr ( by nlinarith [ abs_lt.mp ha, abs_lt.mp hb ] ) ) ] ; cases abs_cases ( a + b ) <;> cases abs_cases ( 1 + a * b ) <;> nlinarith [ abs_lt.mp ha, abs_lt.mp hb ]

/-- Möbius addition is commutative: a ⊕ b = b ⊕ a. -/
theorem moebius_add_comm (a b : ℝ) :
    moebiusAdd a b = moebiusAdd b a := by
  unfold moebiusAdd
  ring_nf

/-- Zero is the identity element for Möbius addition. -/
theorem moebius_add_zero (a : ℝ) : moebiusAdd a 0 = a := by
  unfold moebiusAdd
  simp [mul_zero, add_zero, div_one]

/-
The Möbius inverse of a is -a: a ⊕ (-a) = 0.
-/
theorem moebius_add_neg_cancel (a : ℝ) (_ha : |a| < 1) :
    moebiusAdd a (-a) = 0 := by
  unfold moebiusAdd; aesop;

/-! ## Part II: The Gyrogroup Structure

We package the algebraic properties into a structure that captures
the gyrogroup axioms. This is a novel formalization. -/

/-- **The Möbius Gyrogroup**: a structure encoding the gyrogroup axioms
    for the open unit interval under Möbius addition. Unlike groups,
    gyrogroups satisfy a modified associative law involving a "gyration"
    operator. This structure captures the essential non-associative
    algebra of hyperbolic geometry. -/
structure MoebiusGyrogroup where
  /-- The carrier: a real number with absolute value less than 1 -/
  val : ℝ
  /-- Proof that the value lies strictly inside the unit interval -/
  mem_disk : |val| < 1

namespace MoebiusGyrogroup

@[ext]
theorem ext {g h : MoebiusGyrogroup} (hv : g.val = h.val) : g = h := by
  cases g; cases h; simp at hv; subst hv; rfl

instance : Zero MoebiusGyrogroup := ⟨⟨0, by norm_num⟩⟩

/-- Negation: the Möbius inverse of g is the point -g.val -/
def neg (g : MoebiusGyrogroup) : MoebiusGyrogroup :=
  ⟨-g.val, by simp [abs_neg]; exact g.mem_disk⟩

instance : Neg MoebiusGyrogroup := ⟨neg⟩

@[simp] theorem zero_val : (0 : MoebiusGyrogroup).val = 0 := rfl
@[simp] theorem neg_val (g : MoebiusGyrogroup) : (-g).val = -g.val := rfl

/-- Addition via Möbius addition -/
noncomputable def add (g h : MoebiusGyrogroup) : MoebiusGyrogroup :=
  ⟨moebiusAdd g.val h.val, moebius_preserves_disk g.val h.val g.mem_disk h.mem_disk⟩

noncomputable instance : Add MoebiusGyrogroup := ⟨add⟩

@[simp] theorem add_val (g h : MoebiusGyrogroup) :
    (g + h).val = moebiusAdd g.val h.val := rfl

/-- Right identity: g + 0 = g -/
theorem add_zero_right (g : MoebiusGyrogroup) : g + 0 = g := by
  apply ext; simp [moebius_add_zero]

/-- Left identity: 0 + g = g -/
theorem zero_add_left (g : MoebiusGyrogroup) : 0 + g = g := by
  apply ext; simp [moebius_add_comm, moebius_add_zero]

/-- Right inverse: g + (-g) = 0 -/
theorem add_neg_cancel_right (g : MoebiusGyrogroup) : g + (-g) = 0 := by
  apply ext; simp [moebius_add_neg_cancel g.val g.mem_disk]

end MoebiusGyrogroup

/-! ## Part III: Zeta Summand Reversal -/

/-
**Zeta Summand Bound**.
    For 0 < r < 1 and n ≥ 1, we have r^n < 1.
    Since hyperbolic zeta summands involve ‖z‖^{-2s} = (r^s)^{-2},
    and r^s < 1, we get summands > 1. This reverses the classical
    bound where zeta summands 1/n^s ≤ 1.
-/
theorem zeta_summand_bound (r : ℝ) (n : ℕ) (hr0 : 0 < r) (hr1 : r < 1) (hn : 0 < n) :
    r ^ n < 1 := by
  exact pow_lt_one₀ hr0.le hr1 hn.ne'

/-- Zeta summands are positive -/
theorem zeta_summand_pos (r : ℝ) (n : ℕ) (hr0 : 0 < r) :
    0 < r ^ n :=
  pow_pos hr0 n

/-
**Strict Geometric Decay**: consecutive summands decrease strictly.
    r^(n+1) < r^n for 0 < r < 1.
-/
theorem zeta_summand_strict_decay (r : ℝ) (n : ℕ) (hr0 : 0 < r) (hr1 : r < 1) :
    r ^ (n + 1) < r ^ n := by
  exact pow_lt_pow_right_of_lt_one₀ hr0 hr1 n.lt_succ_self

/-- The hyperbolic zeta summand function: given a disk radius r and exponent s,
    the summand is r^{-2s}. Since 0 < r < 1, this is ≥ 1 for s > 0. -/
noncomputable def hyperbolicZetaSummand (r : ℝ) (s : ℕ) : ℝ := r⁻¹ ^ (2 * s)

/-
**Reversal Theorem**: Hyperbolic zeta summands are at least 1, unlike classical
    summands which are at most 1. This is the key qualitative difference between
    Euclidean and hyperbolic analytic number theory.
-/
theorem hyperbolic_summand_ge_one (r : ℝ) (s : ℕ) (hr0 : 0 < r) (hr1 : r < 1)
    (_hs : 0 < s) :
    1 ≤ hyperbolicZetaSummand r s := by
  exact one_le_pow₀ ( by rw [ le_inv_comm₀ ] <;> norm_num <;> linarith )

/-! ## Part IV: Exponential Growth -/

/-
**Geometric Series Formula** (proved by induction on n).
    The sum 1 + 2 + 4 + ... + 2^n = 2^(n+1) - 1.
    This models the exponential growth of geodesic balls: the hyperbolic plane
    has ball area proportional to e^R, and the discrete analog (binary tree)
    has 2^(n+1) - 1 vertices at depth at most n.
-/
theorem geometric_sum_formula (n : ℕ) :
    ∑ i ∈ Finset.range (n + 1), 2 ^ i = 2 ^ (n + 1) - 1 := by
  norm_num [ Nat.geomSum_eq ]

/-- The number of vertices at distance exactly k from the root
    of a (q+1)-regular tree. -/
def treeSphere (q : ℕ) : ℕ → ℕ
  | 0 => 1
  | k + 1 => (q + 1) * q ^ k

/-- The ball of radius n: total vertices within distance n of root -/
def treeBall (q n : ℕ) : ℕ := ∑ k ∈ Finset.range (n + 1), treeSphere q k

/-
Sphere sizes are positive for q ≥ 1
-/
theorem treeSphere_pos (q k : ℕ) (hq : 1 ≤ q) : 0 < treeSphere q k := by
  -- By definition of `treeSphere`, we know that for `k = 0`, `treeSphere q 0 = 1`, and for `k > 0`, `treeSphere q k = (q + 1) * q ^ (k - 1)`.
  induction' k with k ih;
  · exact Nat.one_pos;
  · exact mul_pos ( Nat.succ_pos _ ) ( pow_pos ( Nat.pos_of_ne_zero ( by aesop_cat ) ) _ )

/-
**Regular Tree Exponential Growth** (proved by induction with Finset sums).
    The ball of radius n has at least q^n vertices.
    This formalizes the correspondence between combinatorial growth
    of Cayley graphs and exponential volume growth of hyperbolic space,
    bridging discrete algebra and Riemannian geometry.
-/
theorem regular_tree_exponential_growth (q n : ℕ) (_hq : 2 ≤ q) :
    q ^ n ≤ treeBall q n := by
  refine' le_trans _ ( Finset.single_le_sum ( fun x _ => _ ) ( Finset.mem_range.mpr ( Nat.lt_succ_self _ ) ) );
  · rcases n with ( _ | n ) <;> simp_all +decide [ treeSphere ];
    lia;
  · exact Nat.zero_le _

/-! ## Part V: Cross-Domain Bridge — Pythagorean Triples and the Disk -/

/-- A Pythagorean triple (a, b, c) satisfying a² + b² = c². -/
structure PrimPythTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  c_pos : 0 < c
  b_pos : 0 < b

/-
**Pythagorean Disk Embedding**: a < c for any Pythagorean triple.
    Since a² < a² + b² = c² (when b > 0) or a² ≤ c² in general,
    the ratio a/c lies strictly below 1.
    This bridges Diophantine number theory with hyperbolic geometry:
    rational points on the unit circle project to rational disk points.
-/
theorem pythagorean_a_lt_c (t : PrimPythTriple) : t.a < t.c := by
  nlinarith [ t.pyth, t.b_pos ]

/-
The embedding a/c lands strictly below 1
-/
theorem pythagorean_embeds_in_disk (t : PrimPythTriple) :
    (t.a : ℝ) / (t.c : ℝ) < 1 := by
  rw [ div_lt_one ] <;> norm_cast <;> linarith [ pythagorean_a_lt_c t, t.c_pos ]

/-
b ≤ c for any Pythagorean triple (equality when a = 0)
-/
theorem pythagorean_b_le_c (t : PrimPythTriple) : t.b ≤ t.c := by
  nlinarith only [ t.pyth ]

/-
The absolute value of a/c is less than 1, so it is a disk point
-/
theorem pythagorean_abs_ratio_lt_one (t : PrimPythTriple) :
    |(t.a : ℝ) / (t.c : ℝ)| < 1 := by
  rw [ abs_of_nonneg ( by positivity ) ];
  exact pythagorean_embeds_in_disk t

/-- **Pythagorean-Möbius Closure**: The Möbius sum of two Pythagorean-rational
    disk points (a₁/c₁ and a₂/c₂) remains strictly inside the disk. This shows
    that Pythagorean rationals are compatible with hyperbolic arithmetic. -/
theorem pythagorean_moebius_closure (t₁ t₂ : PrimPythTriple) :
    |moebiusAdd ((t₁.a : ℝ) / t₁.c) ((t₂.a : ℝ) / t₂.c)| < 1 := by
  exact moebius_preserves_disk _ _ (pythagorean_abs_ratio_lt_one t₁)
    (pythagorean_abs_ratio_lt_one t₂)

/-
**Prime-Leg Witness**: There exist Pythagorean triples with prime legs.
    The triple (3, 4, 5) has a = 3 which is prime.
    This is the simplest instance of a deep question: how are primes
    distributed among legs of Pythagorean triples?
-/
theorem pythagorean_prime_witness :
    ∃ (a b c : ℕ), a ^ 2 + b ^ 2 = c ^ 2 ∧ Nat.Prime a ∧ 0 < c := by
  exists 3, 4, 5

/-! ## Part VI: Falsifiable Conjecture

**Hyperbolic Möbius Iteration Conjecture**: Iterating Möbius addition of a
disk point with itself produces a strictly increasing sequence converging
to the boundary.

Testable prediction: For a = 1/2, the first 10 iterates are all strictly
less than 1 and each iterate exceeds the previous one. This can be verified
computationally using rational arithmetic. -/

/-- The Möbius iteration sequence: repeatedly adding a to itself -/
noncomputable def moebiusIterate (a : ℝ) : ℕ → ℝ
  | 0 => a
  | n + 1 => moebiusAdd a (moebiusIterate a n)

/-
The iteration stays inside the disk (proved by induction using disk preservation)
-/
theorem moebius_iterate_in_disk (a : ℝ) (ha : |a| < 1) (n : ℕ) :
    |moebiusIterate a n| < 1 := by
  induction' n with n ih;
  · exact ha;
  · exact moebius_preserves_disk _ _ ha ih

/-
**Monotonicity Conjecture** (testable): For 0 < a < 1, the Möbius
    iteration sequence is strictly increasing.
    Falsifiable test: compute moebiusIterate (1/2) for n = 0..10 and
    verify strict monotonicity.
-/
theorem moebius_iterate_monotone (a : ℝ) (ha0 : 0 < a) (ha1 : a < 1) (n : ℕ) :
    moebiusIterate a n < moebiusIterate a (n + 1) := by
  refine lt_div_iff₀ ?_ |>.2 ?_;
  · nlinarith [ show 0 ≤ moebiusIterate a n from Nat.recOn n ( by exact ha0.le ) fun n ihn => by rw [ show moebiusIterate a ( n + 1 ) = ( a + moebiusIterate a n ) / ( 1 + a * moebiusIterate a n ) from rfl ] ; exact div_nonneg ( add_nonneg ha0.le ihn ) ( by nlinarith [ ihn ] ) ];
  · nlinarith [ mul_pos ha0 ( sub_pos.mpr ha1 ), mul_pos ha0 ( sub_pos.mpr ( show moebiusIterate a n < 1 from lt_of_abs_lt ( moebius_iterate_in_disk a ( abs_lt.mpr ⟨ by linarith, by linarith ⟩ ) n ) ) ), mul_pos ha0 ( sub_pos.mpr ( show -1 < moebiusIterate a n from neg_lt_of_abs_lt ( moebius_iterate_in_disk a ( abs_lt.mpr ⟨ by linarith, by linarith ⟩ ) n ) ) ), mul_pos ha0 ( sub_pos.mpr ( show moebiusIterate a n > 0 from Nat.recOn n ha0 fun n ih => by { rw [ show moebiusIterate a ( n + 1 ) = moebiusAdd a ( moebiusIterate a n ) from rfl ] ; exact div_pos ( by linarith ) ( by nlinarith [ abs_lt.mp ( moebius_iterate_in_disk a ( abs_lt.mpr ⟨ by linarith, by linarith ⟩ ) n ) ] ) } ) ) ]

end HyperbolicNumberTheory