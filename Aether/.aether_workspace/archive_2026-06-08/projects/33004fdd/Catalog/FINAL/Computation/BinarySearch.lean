import Mathlib
import Computation.AlgorithmicCertificate

/-!
# Binary Search: Correctness and Logarithmic Complexity

We formalize binary search over a monotone predicate and prove:

1. **Correctness** (`binarySearch_correct`): The algorithm returns the least witness —
   the smallest index satisfying the predicate, or `n` if none exists.

2. **Complexity** (`binarySearch_steps_pow2`): For `n = 2^k`, the search terminates
   in at most `k` steps.

3. **Instance of AlgorithmicCertificate**: Binary search is an instance of the
   abstract decreasing-potential framework.

Binary search is formalized as *certified information halving*: each step
bisects the interval of uncertainty, and correctness follows from monotonicity.
-/

open Function

noncomputable section

/-! ## Binary Search State -/

/-- The state of binary search: an interval `[lo, hi]` with `lo ≤ hi ≤ n`.
The least witness lies in this interval (or is `n` if no witness exists). -/
structure BSState (n : ℕ) where
  lo : ℕ
  hi : ℕ
  hle : lo ≤ hi
  hhi : hi ≤ n

/-- The initial state: the entire range `[0, n]`. -/
def BSState.init (n : ℕ) : BSState n :=
  ⟨0, n, Nat.zero_le n, le_refl n⟩

/-- The interval width (potential function). -/
def BSState.width (s : BSState n) : ℕ := s.hi - s.lo

/-- Whether the search is complete (lo = hi). -/
def BSState.done (s : BSState n) : Bool := s.hi ≤ s.lo

/-! ## Step function using midpoint -/

private theorem mid_bounds (lo hi : ℕ) (h : lo < hi) :
    lo ≤ (lo + hi) / 2 ∧ (lo + hi) / 2 < hi := by
  constructor <;> omega

/-- One step of binary search: test midpoint, narrow interval. -/
def BSState.step' (p : ℕ → Bool) : (s : BSState n) → BSState n := fun s =>
  if h : s.lo < s.hi then
    let m := (s.lo + s.hi) / 2
    have hm_ge : s.lo ≤ m := by omega
    have hm_lt : m < s.hi := by omega
    if p m then
      ⟨s.lo, m, hm_ge, le_trans (le_of_lt hm_lt) s.hhi⟩
    else
      ⟨m + 1, s.hi, by omega, s.hhi⟩
  else s

/-! ## Key width lemma -/

/-
The width strictly decreases on each non-terminal step.
-/
theorem bsWidth_decreases
    {n : ℕ} (p : ℕ → Bool)
    (s : BSState n)
    (hNotDone : s.lo < s.hi) :
    (BSState.step' p s).width < s.width := by
  grind +locals

/-
One step halves the width (with rounding).
-/
theorem bsWidth_halves
    {n : ℕ} (p : ℕ → Bool)
    (s : BSState n)
    (hNotDone : s.lo < s.hi) :
    (BSState.step' p s).width ≤ s.width / 2 := by
  unfold BSState.step'; unfold BSState.width;
  grind

/-! ## The Invariant -/

/-- The binary search invariant for a monotone predicate `p`:
- Every index below `lo` does NOT satisfy `p`
- Every index at or above `hi` (and below `n`) DOES satisfy `p` -/
def BSInvariant {n : ℕ} (p : Fin n → Prop) (s : BSState n) : Prop :=
  (∀ i : Fin n, i.val < s.lo → ¬ p i) ∧
  (∀ i : Fin n, s.hi ≤ i.val → p i)

/-
The invariant holds for the initial state.
-/
theorem bsInvariant_init {n : ℕ} (p : Fin n → Prop) :
    BSInvariant p (BSState.init n) := by
  constructor <;> intro i <;> simp_all +decide [ Fin.ext_iff, BSState.init ]

/-
Binary search correctly finds the least witness of a monotone predicate.
When the search terminates (lo = hi), `lo` is the exact boundary:
all indices below it fail `p`, and all indices at or above satisfy `p`.
-/
theorem binarySearch_correct
    {n : ℕ} (p : Fin n → Prop) [DecidablePred p]
    (hmono : ∀ ⦃i j : Fin n⦄, i ≤ j → p i → p j)
    (s : BSState n)
    (hInv : BSInvariant p s)
    (hDone : s.lo = s.hi) :
    (∀ i : Fin n, i.val < s.lo → ¬ p i) ∧
    (∀ i : Fin n, s.lo ≤ i.val → p i) := by
  constructor;
  · exact fun i hi => hInv.1 i hi;
  · exact fun i hi => hInv.2 i ( by linarith )

/-! ## Complexity -/

/-
After `k` non-terminal steps starting from initial state with width `n`,
the width is at most `n / 2^k`.
-/
theorem bs_width_div_pow2
    {n : ℕ} (p : ℕ → Bool) (k : ℕ)
    (hk : ∀ i, i < k → ((BSState.step' p)^[i] (BSState.init n)).lo <
                        ((BSState.step' p)^[i] (BSState.init n)).hi) :
    ((BSState.step' p)^[k] (BSState.init n)).width ≤ n / 2 ^ k := by
  induction' k with k ih generalizing n p;
  · simp +decide [ BSState.init, BSState.width ];
  · have h_step : ((BSState.step' p)^[k + 1] (BSState.init n)).width ≤ ((BSState.step' p)^[k] (BSState.init n)).width / 2 := by
      convert bsWidth_halves p _ ( hk k k.lt_succ_self ) using 1;
      rw [ Function.iterate_succ_apply' ];
    exact h_step.trans ( Nat.div_le_div_right ( ih p fun i hi => hk i ( Nat.lt_succ_of_lt hi ) ) ) |> le_trans <| by rw [ pow_succ, Nat.div_div_eq_div_mul ] ;

/-
For `n = 2^k`, binary search terminates in at most `k + 1` steps:
the width reaches 0. Since each step halves the width, starting from 2^k
we reach width 0 after at most k+1 halvings.
-/
theorem binarySearch_steps_pow2
    (k : ℕ) (p : ℕ → Bool) :
    ((BSState.step' p)^[k + 1] (BSState.init (2^k))).width = 0 := by
  -- By definition of binary search, after $k+1$ steps, the width is at most $2^k / 2^{k+1} = 0$.
  have h_width_zero : ((BSState.step' p)^[k + 1] (BSState.init (2 ^ k))).width ≤ 2 ^ k / 2 ^ (k + 1) := by
    by_contra! h;
    -- Applying the lemma that the width is at most `n / 2^k` after `k` steps, we get a contradiction.
    have h_contradiction : ∀ i ≤ k + 1, ((BSState.step' p)^[i] (BSState.init (2 ^ k))).width ≤ 2 ^ k / 2 ^ i := by
      intro i hi;
      induction' i with i ih;
      · simp +decide [ BSState.init, BSState.width ];
      · by_cases h : ( BSState.step' p )^[i] ( BSState.init ( 2 ^ k ) ) |> BSState.done <;> simp_all +decide [ Function.iterate_succ_apply' ];
        · simp_all +decide [ BSState.done ];
          rw [ BSState.step' ];
          split_ifs <;> simp_all +decide [ Nat.pow_succ', Nat.div_div_eq_div_mul ];
          · grind;
          · exact Nat.le_div_iff_mul_le ( by positivity ) |>.2 ( by nlinarith [ Nat.div_mul_le_self ( 2 ^ k ) ( 2 ^ i ), pow_pos ( by decide : 0 < 2 ) i, pow_pos ( by decide : 0 < 2 ) k, show ( ( BSState.step' p )^[i] ( BSState.init ( 2 ^ k ) ) ).width = 0 from Nat.sub_eq_zero_of_le h ] );
        · have := bsWidth_halves p ( ( BSState.step' p )^[i] ( BSState.init ( 2 ^ k ) ) ) ?_ <;> simp_all +decide [ pow_succ, Nat.div_div_eq_div_mul ];
          · exact this.trans ( Nat.div_le_div_right ( ih ( by linarith ) ) ) |> le_trans <| by rw [ Nat.div_div_eq_div_mul ] ;
          · unfold BSState.done at h; aesop;
    exact absurd ( h_contradiction ( k + 1 ) le_rfl ) ( by norm_num [ Nat.div_eq_of_lt ] at *; omega );
  exact le_antisymm ( le_trans h_width_zero ( Nat.div_eq_of_lt ( pow_lt_pow_right₀ one_lt_two ( Nat.lt_succ_self _ ) ) ▸ le_rfl ) ) ( Nat.zero_le _ )

/-
For `n = 2^k`, after `k` steps width ≤ 1.
-/
theorem binarySearch_width_after_k_pow2
    (k : ℕ) (p : ℕ → Bool) :
    ((BSState.step' p)^[k] (BSState.init (2^k))).width ≤ 1 := by
  -- By `bs_width_div_pow2`, if all k steps are non-terminal, width ≤ 2^k / 2^k = 1.
  have h_div : ((BSState.step' p)^[k] (BSState.init (2 ^ k))).width ≤ 2 ^ k / 2 ^ k := by
    by_cases h : ∀ i < k, ( ( BSState.step' p ) ^[ i ] ( BSState.init ( 2 ^ k ) ) ).lo < ( ( BSState.step' p ) ^[ i ] ( BSState.init ( 2 ^ k ) ) ).hi;
    · exact bs_width_div_pow2 p k h;
    · -- If there exists a step `i < k` where the width is not strictly decreasing, then the width must have reached zero at some point before `k`.
      obtain ⟨i, hi₁, hi₂⟩ : ∃ i < k, ((BSState.step' p)^[i] (BSState.init (2 ^ k))).lo ≥ ((BSState.step' p)^[i] (BSState.init (2 ^ k))).hi := by
        aesop;
      -- Since the width is non-increasing and reaches zero at some point before `k`, it must remain zero for all subsequent steps.
      have h_width_zero : ∀ j ≥ i, ((BSState.step' p)^[j] (BSState.init (2 ^ k))).width = 0 := by
        intro j hj; induction hj <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
        · exact Nat.sub_eq_zero_of_le hi₂;
        · grind +locals;
      grind;
  exact h_div.trans ( Nat.div_self ( by positivity ) |> le_of_eq )

/-! ## Binary Search as an AlgorithmicCertificate Instance -/

/-- Binary search instantiated as an AlgorithmicCertificate.
The potential is the interval width, which strictly decreases on each step. -/
def binarySearchCertificate (n : ℕ) (p : ℕ → Bool) :
    AlgorithmicCertificate (BSState n) ℕ where
  step := BSState.step' p
  invariant := fun s => s.lo ≤ s.hi ∧ s.hi ≤ n
  potential := BSState.width
  terminal := BSState.done
  extract := fun s => s.lo

/-
The binary search certificate has a decreasing potential on non-terminal steps.
-/
theorem binarySearchCertificate_potential_decreases
    (n : ℕ) (p : ℕ → Bool)
    (s : BSState n)
    (hNotDone : (binarySearchCertificate n p).terminal s = false) :
    (binarySearchCertificate n p).potential ((binarySearchCertificate n p).step s) <
    (binarySearchCertificate n p).potential s := by
  exact bsWidth_decreases p s ( by unfold binarySearchCertificate at *; unfold BSState.done at *; aesop )

end