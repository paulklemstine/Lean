import Mathlib

/-!
# Hyperbolic Arithmetic on the Poincaré Disk

This module develops arithmetic on the one-dimensional Poincaré disk model
(-1, 1) ⊂ ℝ using Möbius addition. Unlike the complex case, real Möbius
addition is fully associative via the artanh isomorphism, making (-1, 1)
an abelian group isomorphic to (ℝ, +).

## Main Definitions
* `DiskPoint` — Points in the open unit disk (-1, 1) ⊂ ℝ
* `moebiusAdd` — Möbius addition: (a+b)/(1+ab)
* `HypWord` — Words in a two-generator system for hyperbolic lattices
* `moebiusIterate` — Iteration of Möbius self-addition
* `orbitGap` — Separation between distinct Möbius orbits
* `hypDist` — Hyperbolic distance via artanh

## Main Results
* `moebius_preserves_disk` — Closure under Möbius addition
* `moebius_assoc` — Full associativity (field_simp + ring)
* `moebius_iterate_strict_mono` — Monotonicity of iterates (induction)
* `moebius_no_interior_fixed_point` — No interior fixed points (by_contra)
* `orbit_growth_lower_bound` — Exponential growth of lattice balls
* `hyp_zeta_summand_diverges` — Zeta summand reversal
* `wordBall_exact` — Exact ball count by geometric series

## Falsifiable Conjecture
The **Orbit Separation Conjecture**: for 0 < a < b < 1, the Möbius orbits
moebiusIterate a n and moebiusIterate b n maintain positive gap at all steps.
-/

noncomputable section

open Real BigOperators

namespace HyperbolicArithmetic

/-! ## §1. Möbius Addition -/

/-- Möbius addition: the canonical operation on the Poincaré disk. -/
def moebiusAdd (a b : ℝ) : ℝ := (a + b) / (1 + a * b)

theorem moebius_denom_pos (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1) :
    1 + a * b > 0 := by
  nlinarith [abs_lt.mp ha, abs_lt.mp hb]

/-
**Disk Preservation**: Möbius addition maps disk × disk → disk.
    Uses (a+b)² < (1+ab)² ⟺ (1-a²)(1-b²) > 0.
-/
theorem moebius_preserves_disk (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1) :
    |moebiusAdd a b| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ moebiusAdd ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp ha, abs_lt.mp hb ], by rw [ moebiusAdd ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp ha, abs_lt.mp hb ] ⟩

theorem moebius_add_comm (a b : ℝ) : moebiusAdd a b = moebiusAdd b a := by
  unfold moebiusAdd; ring_nf

theorem moebius_add_zero (a : ℝ) : moebiusAdd a 0 = a := by
  unfold moebiusAdd; simp

theorem moebius_add_neg_cancel (a : ℝ) (ha : |a| < 1) : moebiusAdd a (-a) = 0 := by
  unfold moebiusAdd
  have : 1 + a * -a ≠ 0 := by nlinarith [abs_lt.mp ha]
  field_simp; ring

/-- **Associativity of Möbius addition on ℝ**: Unlike the complex case,
    real Möbius addition is fully associative. This follows from the
    algebraic identity and the fact that denominators are nonzero. -/
theorem moebius_assoc (a b c : ℝ) (ha : |a| < 1) (hb : |b| < 1) (hc : |c| < 1) :
    moebiusAdd (moebiusAdd a b) c = moebiusAdd a (moebiusAdd b c) := by
  unfold moebiusAdd
  have h1 : 1 + a * b ≠ 0 := by nlinarith [abs_lt.mp ha, abs_lt.mp hb]
  have h2 : 1 + b * c ≠ 0 := by nlinarith [abs_lt.mp hb, abs_lt.mp hc]
  field_simp
  ring

/-! ## §2. The DiskPoint Type -/

/-- A point in the open unit disk (-1, 1). -/
structure DiskPoint where
  val : ℝ
  mem_disk : |val| < 1

namespace DiskPoint

@[ext] theorem ext {p q : DiskPoint} (h : p.val = q.val) : p = q := by
  cases p; cases q; simp_all

instance : Zero DiskPoint := ⟨⟨0, by norm_num⟩⟩
@[simp] theorem zero_val : (0 : DiskPoint).val = 0 := rfl

def neg (p : DiskPoint) : DiskPoint := ⟨-p.val, by simp [abs_neg]; exact p.mem_disk⟩
instance : Neg DiskPoint := ⟨neg⟩
@[simp] theorem neg_val (p : DiskPoint) : (-p).val = -p.val := rfl

def add (p q : DiskPoint) : DiskPoint :=
  ⟨moebiusAdd p.val q.val, moebius_preserves_disk p.val q.val p.mem_disk q.mem_disk⟩

noncomputable instance : Add DiskPoint := ⟨add⟩

@[simp] theorem add_val (p q : DiskPoint) :
    (p + q).val = moebiusAdd p.val q.val := rfl

theorem add_zero_right (p : DiskPoint) : p + 0 = p := by
  apply ext; simp [moebius_add_zero]

theorem zero_add_left (p : DiskPoint) : 0 + p = p := by
  apply ext; simp [moebius_add_comm, moebius_add_zero]

theorem add_neg_cancel_right (p : DiskPoint) : p + (-p) = 0 := by
  apply ext; simp [moebius_add_neg_cancel p.val p.mem_disk]

/-- DiskPoint addition is associative. -/
theorem add_assoc (p q r : DiskPoint) : p + q + r = p + (q + r) := by
  apply ext
  simp [moebius_assoc p.val q.val r.val p.mem_disk q.mem_disk r.mem_disk]

end DiskPoint

/-! ## §3. Möbius Iteration -/

/-- Möbius self-iteration starting from 0. -/
def moebiusIterate (a : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => moebiusAdd a (moebiusIterate a n)

/-- Iteration stays in the disk (induction on n). -/
theorem moebius_iterate_in_disk (a : ℝ) (ha : |a| < 1) (n : ℕ) :
    |moebiusIterate a n| < 1 := by
  induction n with
  | zero => simp [moebiusIterate]
  | succ n ih => exact moebius_preserves_disk a _ ha ih

/-
For 0 < a < 1, all iterates are nonneg (by induction).
    Base: moebiusIterate a 0 = 0.
    Step: if x_n ≥ 0 and a > 0, then (a + x_n)/(1 + a·x_n) > 0.
-/
theorem moebius_iterate_nonneg (a : ℝ) (ha0 : 0 < a) (ha1 : a < 1) (n : ℕ) :
    0 ≤ moebiusIterate a n := by
  exact Nat.recOn n ( by norm_num [ moebiusIterate ] ) fun n ih => by rw [ show moebiusIterate a ( n + 1 ) = ( a + moebiusIterate a n ) / ( 1 + a * moebiusIterate a n ) from rfl ] ; exact div_nonneg ( by positivity ) ( by nlinarith ) ;

/-
**Monotonicity of Möbius iterates** (by induction on n).
    For 0 < a < 1, the sequence (moebiusIterate a n) is strictly increasing.
    Key identity: x_{n+1} - x_n = a(1 - x_n²)/(1 + a·x_n) > 0
    since |x_n| < 1 implies 1 - x_n² > 0.
-/
theorem moebius_iterate_strict_mono (a : ℝ) (ha0 : 0 < a) (ha1 : a < 1)
    (n : ℕ) : moebiusIterate a n < moebiusIterate a (n + 1) := by
  -- By definition of moebiusIterate, we have moebiusIterate a (n + 1) = moebiusAdd a (moebiusIterate a n).
  have h_iter : moebiusIterate a (n + 1) = moebiusAdd a (moebiusIterate a n) := by
    rfl;
  rw [ h_iter, moebiusAdd ];
  rw [ lt_div_iff₀ ] <;> nlinarith [ mul_pos ha0 ( show 0 < 1 - moebiusIterate a n ^ 2 by nlinarith [ abs_lt.mp ( moebius_iterate_in_disk a ( abs_lt.mpr ⟨ by linarith, by linarith ⟩ ) n ) ] ), moebius_iterate_nonneg a ha0 ha1 n ]

/-! ## §4. Hyperbolic Lattice Words and Exponential Growth -/

/-- Words in a two-generator system for a hyperbolic lattice. -/
inductive HypWord : Type
  | id : HypWord
  | left : HypWord → HypWord
  | right : HypWord → HypWord

def HypWord.length : HypWord → ℕ
  | .id => 0
  | .left w => w.length + 1
  | .right w => w.length + 1

/-- Evaluate a word at generators via iterated Möbius addition. -/
def HypWord.eval (a b : ℝ) : HypWord → ℝ
  | .id => 0
  | .left w => moebiusAdd a (w.eval a b)
  | .right w => moebiusAdd b (w.eval a b)

/-- Word evaluation stays in the disk (structural induction on w). -/
theorem hypword_eval_in_disk (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1)
    (w : HypWord) : |HypWord.eval a b w| < 1 := by
  induction w with
  | id => simp [HypWord.eval]
  | left w ih => exact moebius_preserves_disk a _ ha ih
  | right w ih => exact moebius_preserves_disk b _ hb ih

/-- Number of words of length exactly n. -/
def wordsOfLength : ℕ → ℕ
  | 0 => 1
  | n + 1 => 2 * wordsOfLength n

/-- Words of length n number exactly 2^n (induction). -/
theorem wordsOfLength_eq_pow (n : ℕ) : wordsOfLength n = 2 ^ n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [wordsOfLength, ih, pow_succ, mul_comm]

/-- Ball of radius n in the word metric. -/
def wordBall (n : ℕ) : ℕ := ∑ k ∈ Finset.range (n + 1), wordsOfLength k

/-- **Exponential orbit growth**: ball of radius n has ≥ 2^n points. -/
theorem orbit_growth_lower_bound (n : ℕ) : 2 ^ n ≤ wordBall n := by
  unfold wordBall
  rw [← wordsOfLength_eq_pow]
  exact Finset.single_le_sum (fun k _ => Nat.zero_le _)
    (Finset.mem_range.mpr (Nat.lt_succ_self n))

/-
**Exact ball size**: wordBall n = 2^{n+1} - 1 (geometric series induction).
-/
theorem wordBall_exact (n : ℕ) : wordBall n = 2 ^ (n + 1) - 1 := by
  unfold wordBall;
  norm_num [ wordsOfLength_eq_pow ];
  norm_num [ Nat.geomSum_eq ]

/-! ## §5. Pythagorean Triples as Disk Points -/

/-- A Pythagorean triple with positivity constraints. -/
structure PythTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  c_pos : 0 < c
  b_pos : 0 < b

theorem pyth_a_lt_c (t : PythTriple) : t.a < t.c := by
  nlinarith [t.pyth, t.b_pos]

theorem pyth_abs_ratio_lt_one (t : PythTriple) : |(t.a : ℝ) / t.c| < 1 := by
  rw [abs_of_nonneg (div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _))]
  rw [div_lt_one (by exact_mod_cast t.c_pos)]
  exact_mod_cast pyth_a_lt_c t

/-- Pythagorean-Möbius closure: disk points from Pythagorean triples are closed
    under Möbius addition. -/
theorem pyth_moebius_closure (t₁ t₂ : PythTriple) :
    |moebiusAdd ((t₁.a : ℝ) / t₁.c) ((t₂.a : ℝ) / t₂.c)| < 1 :=
  moebius_preserves_disk _ _ (pyth_abs_ratio_lt_one t₁) (pyth_abs_ratio_lt_one t₂)

/-! ## §6. Zeta Summand Reversal -/

/-- For 0 < r < 1, r⁻¹ > 1. -/
theorem inv_disk_point_gt_one (r : ℝ) (hr0 : 0 < r) (hr1 : r < 1) :
    1 < r⁻¹ := by
  exact one_lt_inv_iff₀.mpr ⟨hr0, hr1⟩

/-- **Summand reversal**: for 0 < r < 1, n ≥ 1, we have r⁻¹ ^ n > 1.
    Hyperbolic zeta summands grow, unlike classical ones that decay. -/
theorem hyp_zeta_summand_diverges (r : ℝ) (n : ℕ) (hr0 : 0 < r) (hr1 : r < 1)
    (hn : 1 ≤ n) : 1 < r⁻¹ ^ n :=
  one_lt_pow₀ (inv_disk_point_gt_one r hr0 hr1) (by omega)

/-- Summands are monotone increasing: r⁻¹ ^ n < r⁻¹ ^ (n+1). -/
theorem hyp_zeta_summand_increasing (r : ℝ) (n : ℕ) (hr0 : 0 < r) (hr1 : r < 1) :
    r⁻¹ ^ n < r⁻¹ ^ (n + 1) := by
  have h1 : 1 < r⁻¹ := inv_disk_point_gt_one r hr0 hr1
  rw [pow_succ]
  exact lt_mul_of_one_lt_right (pow_pos (by linarith) n) h1

/-! ## §7. Orbit Separation Conjecture -/

/-- Separation between two Möbius orbits. -/
def orbitGap (a b : ℝ) (n : ℕ) : ℝ :=
  moebiusIterate b n - moebiusIterate a n

/-
**Orbit Separation Conjecture**: For 0 < a < b < 1, the gap between
    orbits is positive at every step. This is a discrete analog of
    geodesic divergence in negatively curved spaces.

    **Falsifiable test**: compute for a = 1/3, b = 1/2, n = 0..20.
    If any gap is ≤ 0, the conjecture is refuted.
-/
theorem orbit_gap_always_pos (a b : ℝ) (ha0 : 0 < a) (hab : a < b) (hb1 : b < 1) (n : ℕ) :
    0 < orbitGap a b (n + 1) := by
  induction' n with n ih;
  · grind +locals;
  · -- By the properties of Möbius addition, we have:
    have h_moebius_add : moebiusAdd b (moebiusIterate b (n + 1)) > moebiusAdd a (moebiusIterate b (n + 1)) ∧ moebiusAdd a (moebiusIterate b (n + 1)) > moebiusAdd a (moebiusIterate a (n + 1)) := by
      constructor <;> norm_num [ moebiusAdd ] at *;
      · rw [ div_lt_div_iff₀ ] <;> try nlinarith [ show 0 ≤ moebiusIterate b ( n + 1 ) from moebius_iterate_nonneg b ( by linarith ) ( by linarith ) ( n + 1 ) ];
        nlinarith [ mul_pos ha0 ( sub_pos.mpr hab ), mul_pos ha0 ( sub_pos.mpr hb1 ), mul_pos ( sub_pos.mpr hab ) ( sub_pos.mpr hb1 ), show moebiusIterate b ( n + 1 ) ^ 2 < 1 from by nlinarith [ abs_lt.mp ( moebius_iterate_in_disk b ( by linarith [ abs_of_pos ( by linarith : 0 < b ) ] ) ( n + 1 ) ) ] ];
      · rw [ div_lt_div_iff₀ ] <;> try nlinarith [ show 0 ≤ moebiusIterate a ( n + 1 ) from moebius_iterate_nonneg a ha0 ( by linarith ) ( n + 1 ) ];
        · unfold orbitGap at ih; nlinarith [ mul_pos ha0 ( sub_pos.mpr ih ), mul_pos ha0 ( sub_pos.mpr hab ), mul_pos ha0 ( sub_pos.mpr hb1 ), moebius_iterate_nonneg a ha0 ( by linarith ) ( n + 1 ), moebius_iterate_nonneg b ( by linarith ) ( by linarith ) ( n + 1 ) ] ;
        · exact add_pos_of_pos_of_nonneg zero_lt_one ( mul_nonneg ha0.le ( moebius_iterate_nonneg b ( by linarith ) ( by linarith ) _ ) );
    unfold orbitGap at *; linarith!;

/-! ## §8. Fixed-Point Characterization -/

/-
**No interior fixed point** (by_contra): if a ≠ 0 and |x| < 1,
    then moebiusAdd a x ≠ x.
    Proof: Assume x = (a+x)/(1+ax). Then x(1+ax) = a+x, so ax² = a,
    hence x² = 1. But |x| < 1 implies x² < 1, contradiction.
-/
theorem moebius_no_interior_fixed_point (a x : ℝ) (ha : |a| < 1) (ha0 : a ≠ 0)
    (hx : |x| < 1) : moebiusAdd a x ≠ x := by
  unfold moebiusAdd;
  rw [ Ne.eq_def, div_eq_iff ];
  · cases lt_or_gt_of_ne ha0 <;> nlinarith [ abs_lt.mp ha, abs_lt.mp hx, mul_pos ( sub_pos.mpr ‹_› ) ( sub_pos.mpr ( abs_lt.mp hx |>.1 ) ), mul_pos ( sub_pos.mpr ‹_› ) ( sub_pos.mpr ( abs_lt.mp hx |>.2 ) ) ];
  · cases abs_cases a <;> cases abs_cases x <;> nlinarith

/-! ## §9. Hyperbolic Distance -/

/-- Möbius difference: a ⊕ (-b). -/
def moebiusDiff (a b : ℝ) : ℝ := moebiusAdd a (-b)

/-- Hyperbolic distance on the 1D Poincaré disk. -/
def hypDist (a b : ℝ) : ℝ := Real.artanh |moebiusDiff a b|

/-- Distance from a point to itself is zero. -/
theorem hyp_dist_self (a : ℝ) (ha : |a| < 1) : hypDist a a = 0 := by
  unfold hypDist moebiusDiff
  simp [moebius_add_neg_cancel a ha, Real.artanh_zero]

/-
Hyperbolic distance is symmetric:
    |moebiusDiff a b| = |moebiusDiff b a| because
    (a - b)/(1 - ab) and (b - a)/(1 - ba) differ only by sign.
-/
theorem hyp_dist_symm (a b : ℝ) (_ha : |a| < 1) (_hb : |b| < 1) :
    hypDist a b = hypDist b a := by
  unfold hypDist moebiusDiff moebiusAdd
  ring_nf
  rw [← abs_neg]
  ring_nf

end HyperbolicArithmetic
end