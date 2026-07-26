import Mathlib

/-!
# The three-halves steering word

This file formalizes the elementary arithmetic core of the steering word attached
to nearest-integer approximations to `(3/2)^n`.  It proves endpoint
reconstruction from a finite steering block, rigidity of repeated blocks,
divisibility forced by long zero blocks, exclusion of nonzero zero tails, and
the five-symbol alphabet bound coming from nearest-integer errors.
-/

namespace ThreeHalvesSteeringCore

/-- The integer correction in the recurrence `2 m (n+1) = 3 m n + t n`. -/
def steering (m : ℕ → ℤ) (n : ℕ) : ℤ := 2 * m (n + 1) - 3 * m n

/-- The weighted contribution of a length-`k` steering block beginning at `n`. -/
def blockWeight (t : ℕ → ℤ) (n : ℕ) : ℕ → ℤ
  | 0 => 0
  | k + 1 => 3 * blockWeight t n k + 2 ^ k * t (n + k)

/-- Iterating the steering recurrence reconstructs the endpoint of every block. -/
theorem endpoint_reconstruction (m : ℕ → ℤ) (n k : ℕ) :
    2 ^ k * m (n + k) = 3 ^ k * m n + blockWeight (steering m) n k := by
  induction' k with k ih generalizing n <;>
    simp_all +decide [pow_succ', mul_assoc, blockWeight]
  have h₀ := ih n
  have h₁ := ih (n + 1)
  simp_all +decide [← add_assoc, steering]
  ring_nf
  grind

/-- Pointwise equal finite blocks have equal weighted corrections. -/
theorem blockWeight_eq_of_blocks (t : ℕ → ℤ) {a b k : ℕ}
    (h : ∀ j < k, t (a + j) = t (b + j)) :
    blockWeight t a k = blockWeight t b k := by
  induction' k with k ih
  · rfl
  · rw [blockWeight, blockWeight,
      ih fun j hj => h j (Nat.lt_succ_of_lt hj), h k (Nat.lt_succ_self k)]

/-- A repeated steering block forces an exact scaling relation between endpoint differences. -/
theorem repeated_block_rigidity (m : ℕ → ℤ) {a b k : ℕ}
    (h : ∀ j < k, steering m (a + j) = steering m (b + j)) :
    2 ^ k * (m (a + k) - m (b + k)) = 3 ^ k * (m a - m b) := by
  have h₁ := endpoint_reconstruction m a k
  have h₂ := endpoint_reconstruction m b k
  linarith [blockWeight_eq_of_blocks (steering m) h]

/-- If two equal steering blocks also have the same terminal value, their initial values agree. -/
theorem repeated_block_eq_start_of_eq_end (m : ℕ → ℤ) {a b k : ℕ}
    (hblock : ∀ j < k, steering m (a + j) = steering m (b + j))
    (hend : m (a + k) = m (b + k)) :
    m a = m b := by
  contrapose! hend with h;
  exact fun h' => h <| by have := repeated_block_rigidity m hblock; simp_all +decide [ sub_eq_iff_eq_add ] ;

/-- The complete steering word and its initial value uniquely determine the integer orbit. -/
theorem steering_injective_with_initial {m₁ m₂ : ℕ → ℤ}
    (hzero : m₁ 0 = m₂ 0)
    (hsteer : ∀ n, steering m₁ n = steering m₂ n) :
    m₁ = m₂ := by
  exact funext fun n => Nat.recOn n hzero fun n ih => by have := hsteer n; rw [ show steering m₁ n = 2 * m₁ ( n + 1 ) - 3 * m₁ n from rfl, show steering m₂ n = 2 * m₂ ( n + 1 ) - 3 * m₂ n from rfl ] at this; norm_num at *; linarith;

/-- A zero steering block forces a power of two to divide its initial value. -/
theorem zero_block_forces_two_power_dvd (m : ℕ → ℤ) {n k : ℕ}
    (h : ∀ j < k, steering m (n + j) = 0) :
    (2 : ℤ) ^ k ∣ m n := by
  have heq : 2 ^ k * m (n + k) = 3 ^ k * m n := by
    rw [endpoint_reconstruction]
    induction' k with k ih <;> simp_all +decide [blockWeight]
    exact ih fun j hj => h j hj.le
  exact Int.dvd_of_dvd_mul_right_of_gcd_one (Dvd.intro _ heq)
    (by cases k <;> norm_num [Int.gcd, Int.natAbs_pow])

/-- An infinite zero steering tail can begin only at the zero integer state. -/
theorem infinite_zero_tail_forces_zero (m : ℕ → ℤ) {n : ℕ}
    (h : ∀ j, steering m (n + j) = 0) :
    m n = 0 := by
  have hdiv : ∀ k : ℕ, (2 : ℤ) ^ k ∣ m n :=
    fun k => zero_block_forces_two_power_dvd m fun j _ => h j
  by_contra hne
  obtain ⟨k, hk⟩ : ∃ k : ℕ, 2 ^ k > Int.natAbs (m n) :=
    pow_unbounded_of_one_lt _ one_lt_two
  exact hk.not_ge (Nat.le_of_dvd (Int.natAbs_pos.mpr hne)
    (by simpa [← Int.natCast_dvd_natCast] using hdiv k))

/-- Nearest-integer error bounds constrain every steering correction to five integers. -/
theorem steering_five_symbol_alphabet (m : ℕ → ℤ) (eps : ℕ → ℝ)
    (horbit : ∀ n, (m n : ℝ) + eps n = (3 / 2 : ℝ) ^ n)
    (hlower : ∀ n, -(1 / 2 : ℝ) ≤ eps n)
    (hupper : ∀ n, eps n < 1 / 2) (n : ℕ) :
    steering m n ∈ ({-2, -1, 0, 1, 2} : Set ℤ) := by
  have hsteer : ∀ q, (steering m q : ℝ) = 3 * eps q - 2 * eps (q + 1) := by
    intro q
    rw [show (steering m q : ℝ) = 2 * m (q + 1) - 3 * m q by norm_cast]
    have hq := horbit q
    have hqs := horbit (q + 1)
    norm_num [pow_succ'] at *
    linarith
  have hrange : ∀ q, -2 ≤ steering m q ∧ steering m q ≤ 2 := by
    intro q
    constructor
    · exact Int.le_of_lt_add_one <| by
        rw [← @Int.cast_lt ℝ]
        push_cast
        linarith [hsteer q, hlower q, hupper q, hlower (q + 1), hupper (q + 1)]
    · exact Int.le_of_lt_add_one <| by
        rw [← @Int.cast_lt ℝ]
        push_cast
        linarith [hsteer q, hlower q, hupper q, hlower (q + 1), hupper (q + 1)]
  rcases hrange n with ⟨hnl, hnu⟩
  interval_cases steering m n <;> simp +decide

/-- A computable nearest-integer convention for `(3/2)^n`, with half-integers rounded up. -/
def roundedThreeHalves (n : ℕ) : ℕ :=
  (2 * 3 ^ n + 2 ^ n) / (2 * 2 ^ n)

/--
The rounding formula differs from `(3/2)^n` by an amount in the
half-open nearest-integer interval.
-/
theorem roundedThreeHalves_bounds (n : ℕ) :
    (roundedThreeHalves n : ℝ) - 1 / 2 ≤ (3 / 2 : ℝ) ^ n ∧
      (3 / 2 : ℝ) ^ n < (roundedThreeHalves n : ℝ) + 1 / 2 := by
  field_simp;
  rw [ show ( 3 / 2 : ℝ ) ^ n = ( 3 ^ n : ℝ ) / ( 2 ^ n : ℝ ) by rw [ div_pow ] ];
  rw [ mul_div, le_div_iff₀, div_lt_iff₀ ] <;> norm_cast <;> norm_num [ roundedThreeHalves ];
  rw [ Int.subNatNat_eq_coe ] ; push_cast ; constructor <;> nlinarith [ Nat.div_mul_le_self ( 2 * 3 ^ n + 2 ^ n ) ( 2 * 2 ^ n ), Nat.div_add_mod ( 2 * 3 ^ n + 2 ^ n ) ( 2 * 2 ^ n ), Nat.mod_lt ( 2 * 3 ^ n + 2 ^ n ) ( by positivity : 0 < ( 2 * 2 ^ n ) ), pow_pos ( by decide : 0 < 2 ) n, pow_pos ( by decide : 0 < 3 ) n ]

/-- The signed rounding error for the computable nearest-integer orbit. -/
noncomputable def roundedError (n : ℕ) : ℝ :=
  (3 / 2 : ℝ) ^ n - roundedThreeHalves n

/-- The rounded value and signed error reconstruct the exact power. -/
theorem rounded_add_error (n : ℕ) :
    (roundedThreeHalves n : ℝ) + roundedError n = (3 / 2 : ℝ) ^ n := by
  simp [roundedError]

/-- Every signed rounding error belongs to the standard half-open interval. -/
theorem roundedError_mem (n : ℕ) :
    -(1 / 2 : ℝ) ≤ roundedError n ∧ roundedError n < 1 / 2 := by
  convert roundedThreeHalves_bounds n using 1 ; ring;
  · constructor <;> intro h <;> rw [ roundedError ] at * <;> linarith [ rounded_add_error n ];
  · unfold roundedError; constructor <;> intro <;> linarith;

/-- The concrete steering word of rounded powers uses only five symbols. -/
theorem rounded_steering_five_symbol_alphabet (n : ℕ) :
    steering (fun q => (roundedThreeHalves q : ℤ)) n ∈
      ({-2, -1, 0, 1, 2} : Set ℤ) := by
  convert steering_five_symbol_alphabet _ _ _ _ _ _;
  exact fun n => ( 3 / 2 : ℝ ) ^ n - ↑ ( roundedThreeHalves n );
  · aesop;
  · exact fun n => roundedError_mem n |>.1;
  · exact fun n => by have := roundedError_mem n; norm_num [ roundedError ] at *; linarith;

/-- Every rounded power of three-halves is a positive natural number. -/
theorem roundedThreeHalves_pos (n : ℕ) : 0 < roundedThreeHalves n := by
  exact Nat.div_pos ( by linarith [ pow_pos ( by decide : 0 < 2 ) n, pow_le_pow_left' ( show 2 ≤ 3 by decide ) n ] ) ( by positivity )

/-- The concrete steering word has no infinite zero tail. -/
theorem rounded_steering_not_eventually_zero (n : ℕ) :
    ¬ ∀ j, steering (fun q => (roundedThreeHalves q : ℤ)) (n + j) = 0 := by
  intro h;
  have := infinite_zero_tail_forces_zero ( fun q => Int.ofNat ( roundedThreeHalves q ) ) h; norm_cast at this; simp_all +decide;
  exact absurd this ( ne_of_gt ( roundedThreeHalves_pos n ) )

/-- The first twelve rounded values are `1,2,2,3,5,8,11,17,26,38,58,86`. -/
theorem roundedThreeHalves_first_values :
    List.ofFn (fun i : Fin 12 => roundedThreeHalves i) =
      [1, 2, 2, 3, 5, 8, 11, 17, 26, 38, 58, 86] := by
  decide

/-- The first eleven corrections are `1,-2,0,1,1,-2,1,1,-2,2,-2`. -/
theorem steering_first_values :
    List.ofFn (fun i : Fin 11 => steering (fun n => (roundedThreeHalves n : ℤ)) i) =
      [1, -2, 0, 1, 1, -2, 1, 1, -2, 2, -2] := by
  decide

end ThreeHalvesSteeringCore