import Mathlib

/-! # Mathematical Uncanny Valley Theory

We formalize the "uncanny valley" phenomenon for mathematical proofs:
as a proof becomes more rigorous, trust increases—until it is "almost rigorous"
(most steps verified, but with small gaps), at which point trust *drops sharply*
below even the trust given to informal sketches, before recovering for
fully rigorous proofs.

## Mathematical model

We model a proof as having `n` total steps, of which `k` are formally verified.
The **suspicion** of such a proof is a function of `(k, n)` that captures how
much a mathematician distrusts the proof. We study two kernels:

- **Symmetric suspicion**: `S(k,n) = k * (n - k)` — maximum at `k = n/2`
- **Asymmetric suspicion**: `A(k,n) = k² * (n - k)` — maximum shifted toward `k = 2n/3`

The key insight: the asymmetric kernel models the uncanny valley because proofs
that are *almost* complete (high `k/n`) are more suspicious than clearly incomplete
ones. This is because:
- A sketch (`k ≈ 0`) is accepted as intuition — no one expects formal rigor.
- An almost-complete proof (`k ≈ n-1`) raises suspicion: "if it's so close to
  being rigorous, why isn't it complete? What subtle error lurks in the gap?"
- A complete proof (`k = n`) eliminates all suspicion.

## Novel structure: `SuspicionProfile`

We define a `SuspicionProfile` to abstractly capture any function with the
uncanny valley shape: zero suspicion at the endpoints, with a valley (maximum
suspicion) that is closer to the "complete" end than the "sketch" end.

## Main results

1. `uncanny_valley_ordering`: For `n ≥ 3`, a proof with one gap (`k = n-1`)
   generates strictly more suspicion than a proof with one verified step (`k = 1`).

2. `valley_depth_grows`: The depth of the uncanny valley grows with proof length.

3. `trust_recovery_at_full_rigor`: Full verification (`k = n`) achieves maximum
   trust, escaping the uncanny valley.

4. `asym_exceeds_sym_near_top`: Near the top of the rigor spectrum,
   the asymmetric kernel dominates the symmetric one.

5. `valley_position_asymmetry`: The maximum of the asymmetric kernel occurs
   in the upper portion of the rigor range.

## Conjecture

The **Uncanny Valley Gap Conjecture** states that for any proof of length `n ≥ 4`,
the ratio of suspicion at `k = n-1` to the maximum suspicion is bounded below by
`1/2`. This is testable: compute the ratio for specific `n` values.
-/

noncomputable section

open Finset BigOperators

/-! ## Core definitions -/

/-- The symmetric suspicion kernel: `k * (n - k)`.
    This is the simplest model of proof suspicion, maximized at `k = n/2`.
    It treats "missing steps near the beginning" and "missing steps near the end"
    symmetrically, which fails to capture the uncanny valley effect. -/
def symSuspicion (k n : ℕ) : ℕ := k * (n - k)

/-- The asymmetric suspicion kernel: `k² * (n - k)`.
    This models the uncanny valley: the quadratic weight on `k` means that proofs
    with high rigor (large `k`) but small gaps (small `n - k`) generate
    disproportionately high suspicion. The maximum shifts toward `k = 2n/3`,
    capturing the phenomenon that "almost-right" proofs are more suspicious
    than clearly informal ones. -/
def asymSuspicion (k n : ℕ) : ℕ := k ^ 2 * (n - k)

/-- A `SuspicionProfile` captures the abstract shape of an uncanny valley function.
    It assigns a suspicion level to each rigor level `k ∈ {0, ..., n}`, satisfying:
    1. Zero suspicion at both endpoints (sketch and complete proof)
    2. The valley (maximum suspicion) exists strictly between the endpoints
    3. The valley is in the upper half of the rigor spectrum (uncanny valley property)
    This is a novel mathematical structure formalizing the uncanny valley for proofs. -/
structure SuspicionProfile (n : ℕ) where
  /-- The suspicion function, defined on rigor levels 0 through n -/
  suspicion : ℕ → ℕ
  /-- No suspicion for a pure sketch (k = 0) -/
  zero_at_sketch : suspicion 0 = 0
  /-- No suspicion for a complete proof (k = n) -/
  zero_at_complete : suspicion n = 0
  /-- There exists a valley (maximum suspicion) strictly between the endpoints -/
  valley_exists : ∃ v, 0 < v ∧ v < n ∧ ∀ k, k ≤ n → suspicion k ≤ suspicion v
  /-- The valley is in the upper half: the maximizer is above n/2 -/
  valley_in_upper_half : ∃ v, 0 < v ∧ v < n ∧
    (∀ k, k ≤ n → suspicion k ≤ suspicion v) ∧ n / 2 < v

/-! ## Basic properties of the suspicion kernels -/

@[simp] theorem symSuspicion_zero (n : ℕ) : symSuspicion 0 n = 0 := by
  simp [symSuspicion]

@[simp] theorem symSuspicion_complete (n : ℕ) : symSuspicion n n = 0 := by
  simp [symSuspicion]

@[simp] theorem asymSuspicion_zero (n : ℕ) : asymSuspicion 0 n = 0 := by
  simp [asymSuspicion]

@[simp] theorem asymSuspicion_complete (n : ℕ) : asymSuspicion n n = 0 := by
  simp [asymSuspicion]

/-! ## The Uncanny Valley Ordering Theorem -/

/-
**The Uncanny Valley Ordering Theorem**: For any proof of length `n ≥ 3`,
    a proof with exactly one unverified step (`k = n - 1`) generates strictly
    more asymmetric suspicion than a proof with exactly one verified step (`k = 1`).

    This is the core formalization: an almost-complete proof with one `sorry`
    is more suspicious than a bare sketch with one verified lemma.
-/
theorem uncanny_valley_ordering (n : ℕ) (hn : 3 ≤ n) :
    asymSuspicion 1 n < asymSuspicion (n - 1) n := by
  rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ asymSuspicion ] at *;
  nlinarith

/-
The symmetric suspicion kernel does NOT exhibit the uncanny valley:
    `S(1, n) = S(n-1, n)` for all `n ≥ 1`. This shows that the asymmetry in
    the kernel is essential for modeling the uncanny valley.
-/
theorem symSuspicion_no_valley (n : ℕ) (hn : 1 ≤ n) :
    symSuspicion 1 n = symSuspicion (n - 1) n := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ symSuspicion ]

/-! ## Valley Depth Growth -/

/-
The suspicion at `k = n - 1` (almost-complete proof with one sorry)
    equals `(n-1)²`. This grows quadratically in `n`, meaning longer proofs
    have a deeper uncanny valley.
-/
theorem asym_suspicion_at_penultimate (n : ℕ) (hn : 1 ≤ n) :
    asymSuspicion (n - 1) n = (n - 1) ^ 2 := by
  unfold asymSuspicion;
  cases n <;> aesop

/-
**Valley Depth Growth**: The depth of the uncanny valley at the penultimate
    step grows strictly with proof length. Longer proofs have deeper valleys:
    adding one more step to a proof makes the "one sorry remaining" case
    even more suspicious.
-/
theorem valley_depth_grows (n : ℕ) (hn : 2 ≤ n) :
    asymSuspicion (n - 1) n < asymSuspicion n (n + 1) := by
  unfold asymSuspicion; rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
  linarith [ Nat.zero_le n ]

/-! ## Trust Recovery Theorem -/

/-- The **trust level** of a proof with `k` verified steps out of `n`.
    Defined as `n³ - asymSuspicion(k, n)`, so higher is better.
    The `n³` normalization ensures trust is always non-negative for `k ≤ n`. -/
def proofTrust (k n : ℕ) : ℕ := n ^ 3 - asymSuspicion k n

/-
**Trust Recovery at Full Rigor**: A fully verified proof (`k = n`) achieves
    the maximum possible trust level `n³`. Full formal verification escapes
    the uncanny valley entirely.
-/
theorem trust_recovery_at_full_rigor (n : ℕ) :
    proofTrust n n = n ^ 3 := by
  unfold proofTrust asymSuspicion; aesop;

/-
An almost-complete proof has strictly less trust than a complete one,
    for any proof of length ≥ 2. This is the "last sorry" penalty:
    the final unverified step costs `(n-1)²` trust units.
-/
theorem last_sorry_penalty (n : ℕ) (hn : 2 ≤ n) :
    proofTrust (n - 1) n < proofTrust n n := by
  unfold proofTrust;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ asymSuspicion ]

/-! ## Asymmetric vs. Symmetric Suspicion -/

/-
Near the top of the rigor spectrum, the asymmetric suspicion kernel
    dominates the symmetric one. For `k = n - 1` with `n ≥ 3`, the
    asymmetric suspicion is strictly larger. This formalizes that the
    uncanny valley effect is *stronger* than a naïve symmetric model predicts.
-/
theorem asym_exceeds_sym_near_top (n : ℕ) (hn : 3 ≤ n) :
    symSuspicion (n - 1) n < asymSuspicion (n - 1) n := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ symSuspicion, asymSuspicion ];
  grind

/-! ## Valley Position -/

/-
For `n ≥ 6`, the asymmetric suspicion at the position `2*n/3` (rounded down)
    exceeds the suspicion at `n/3`. This establishes that the valley is
    concentrated in the upper portion of the rigor spectrum.
-/
theorem valley_position_asymmetry (n : ℕ) (hn : 6 ≤ n) :
    asymSuspicion (n / 3) n < asymSuspicion (2 * n / 3) n := by
  refine' lt_of_lt_of_le _ ( Nat.mul_le_mul_right _ <| Nat.pow_le_pow_left ( show n / 3 * 2 ≤ 2 * n / 3 from _ ) 2 );
  · unfold asymSuspicion; ring_nf;
    rw [ mul_assoc ];
    exact Nat.mul_lt_mul_of_pos_left ( by omega ) ( pow_pos ( Nat.div_pos ( by linarith ) zero_lt_three ) 2 );
  · grind

/-! ## Cumulative Suspicion -/

/-- The total asymmetric suspicion over all rigor levels. -/
def totalAsymSuspicion (n : ℕ) : ℕ :=
  ∑ k ∈ range (n + 1), asymSuspicion k n

/-- The total symmetric suspicion over all rigor levels. -/
def totalSymSuspicion (n : ℕ) : ℕ :=
  ∑ k ∈ range (n + 1), symSuspicion k n

/-
**The Integral Valley Theorem**: The total asymmetric suspicion over all
    rigor levels exceeds the total symmetric suspicion for `n ≥ 3`.
    The uncanny valley is not just a local phenomenon — it increases
    the *total* area under the suspicion curve.
-/
theorem integral_valley_dominance (n : ℕ) (hn : 3 ≤ n) :
    totalSymSuspicion n < totalAsymSuspicion n := by
  fapply Finset.sum_lt_sum;
  · exact fun i hi => Nat.mul_le_mul_right _ ( by cases i <;> norm_num ; nlinarith );
  · exact ⟨ 2, Finset.mem_range.mpr ( by linarith ), by unfold symSuspicion asymSuspicion; nlinarith [ Nat.sub_add_cancel ( by linarith : 2 ≤ n ) ] ⟩

/-! ## Constructing a SuspicionProfile from the asymmetric kernel -/

/-
The asymmetric suspicion kernel gives rise to a valid `SuspicionProfile`
    for any `n ≥ 6`. This witnesses that the uncanny valley phenomenon is
    not just hypothetical but is realized by a concrete mathematical function.
-/
theorem asymSuspicion_is_profile (n : ℕ) (hn : 6 ≤ n) :
    ∃ v, 0 < v ∧ v < n ∧
      (∀ k, k ≤ n → asymSuspicion k n ≤ asymSuspicion v n) ∧
      n / 2 < v := by
  -- By definition of `asymSuspicion`, we know that `asymSuspicion k n` is maximized at `k = 2*n/3`.
  obtain ⟨v, hv_bounds, hv_max⟩ : ∃ v ∈ Finset.range (n + 1), (∀ k ∈ Finset.range (n + 1), asymSuspicion k n ≤ asymSuspicion v n) ∧ n / 2 < v := by
    -- By definition of `asymSuspicion`, we know that `asymSuspicion k n` is maximized at `k = 2*n/3`. Hence, we can choose `v = 2*n/3`.
    obtain ⟨v, hv_bounds, hv_max⟩ : ∃ v ∈ Finset.range (n + 1), (∀ k ∈ Finset.range (n + 1), asymSuspicion k n ≤ asymSuspicion v n) := by
      exact Finset.exists_max_image _ _ ⟨ _, Finset.mem_range.mpr <| Nat.succ_pos _ ⟩;
    by_cases hv_le : v ≤ n / 2;
    · have := hv_max ( n - 1 ) ?_ <;> simp_all +decide [ asymSuspicion ];
      contrapose! hv_max;
      refine' ⟨ v + 1, _, _ ⟩;
      · omega;
      · zify;
        rw [ Nat.cast_sub, Nat.cast_sub ] <;> push_cast <;> nlinarith only [ hn, hv_le, Nat.div_mul_le_self n 2 ];
    · grind;
  cases lt_or_eq_of_le ( Finset.mem_range_succ_iff.mp hv_bounds ) <;> simp_all +decide;
  · exact ⟨ v, by linarith [ Nat.div_add_mod n 2, Nat.mod_lt n two_pos ], by linarith, hv_max ⟩;
  · grind +locals

/-! ## Conjecture: Valley Monotonicity -/

/-
**Valley Monotonicity Conjecture** (falsifiable):
    For any proof of length `n ≥ 3`, the asymmetric suspicion function is
    strictly monotone increasing on the interval `{0, 1, ..., 2n/3}`.
    That is, increasing the number of verified steps (while staying below
    the valley peak) always increases suspicion.

    This captures the core uncanny valley intuition: *partial rigor is worse*
    than no rigor at all, and the more partial it gets, the worse it is,
    until you cross the valley peak at 2n/3.

    **Computational test**: For each `n = 3, 4, ..., 1000` and each
    `0 ≤ k₁ < k₂ ≤ 2n/3`, verify `asymSuspicion(k₁, n) < asymSuspicion(k₂, n)`.
    Any counterexample would disprove the conjecture.

    Evidence (computed for n = 3..22, all pass):
    - `n = 6`: values at k=0..4 are [0, 5, 16, 27, 32] — strictly increasing ✓
    - `n = 9`: values at k=0..6 are [0, 8, 28, 54, 80, 100, 108] ✓
    - `n = 10`: values at k=0..6 are [0, 9, 32, 63, 96, 125, 144] ✓
-/
theorem valley_monotonicity_conjecture (n k₁ k₂ : ℕ) (hn : 3 ≤ n)
    (hk₁ : k₁ < k₂) (hk₂ : 3 * k₂ ≤ 2 * n) :
    asymSuspicion k₁ n < asymSuspicion k₂ n := by
  unfold asymSuspicion;
  zify;
  rw [ Nat.cast_sub, Nat.cast_sub ] <;> try linarith;
  nlinarith [ Nat.mul_le_mul_left k₁ hk₁, Nat.mul_le_mul_left k₂ hk₁, Nat.mul_le_mul_left k₁ hk₂, Nat.mul_le_mul_left k₂ hk₂ ]

end