import Mathlib

/-!
# Collatz Parity Cylinders and Density Theory

We develop a formal theory of the Collatz dynamical system through the lens of
parity vectors and arithmetic cylinders. The central insight is that the first k
steps of any Collatz orbit are completely determined by the starting value's residue
class modulo 2^k, creating an exact correspondence between symbolic dynamics
(parity words) and arithmetic structure (congruence classes).

## Main results

* `step_congr_mod`: The Collatz step preserves congruences with halved modulus.
* `parityWord_determined_by_residue`: The parity word of length k depends only on n mod 2^k.
* `step_odd_result_even`: After an odd step, the result is always even.
* `no_consecutive_odd_parities`: Realized parity words never have consecutive odd entries.
* `residue_count_upper`/`residue_count_lower`: Bounds on residue-class counting.

## References

This formalizes the combinatorial core of the Terras approach to Collatz density theory.
The parity-cylinder classification is the symbolic-dynamics analogue of studying
finite-depth orbit prefixes via residue classes.
-/

namespace Collatz

/-- The standard Collatz step: divide by 2 if even, apply 3n+1 if odd. -/
def step (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-- The parity word of length k for starting value n.
    Records whether each iterate is odd (`true`) or even (`false`).
    This is the symbolic encoding of the first k steps of the Collatz orbit. -/
def parityWord (k : ℕ) (n : ℕ) : Fin k → Bool :=
  fun i => decide (Odd (step^[i.val] n))

/-- The number of odd entries (true values) in a boolean word. -/
def oddCount (k : ℕ) (w : Fin k → Bool) : ℕ :=
  (Finset.univ.filter (fun i => w i = true)).card

/-- The number of even entries (false values) in a boolean word. -/
def evenCount (k : ℕ) (w : Fin k → Bool) : ℕ :=
  (Finset.univ.filter (fun i => w i = false)).card

/-- Affine coefficients (A, B, D) for the Collatz iterate along a parity word.
    After k steps with word w, the iterate satisfies D * x_k = A * n + B
    (when the word is realized by n). -/
def affineCoeffs (k : ℕ) (w : Fin k → Bool) : ℤ × ℤ × ℤ :=
  match k with
  | 0 => (1, 0, 1)
  | k' + 1 =>
    let w' : Fin k' → Bool := fun i => w ⟨i.val, by omega⟩
    let (A, B, D) := affineCoeffs k' w'
    if w ⟨k', by omega⟩ then (3 * A, 3 * B + D, D)
    else (A, B, 2 * D)

/-- A parity word is a "descent word" if the multiplicative factor satisfies
    3^(oddCount) < 2^(evenCount), meaning the affine iterate contracts for large n. -/
def isDescentWord (k : ℕ) (w : Fin k → Bool) : Prop :=
  3 ^ oddCount k w < 2 ^ evenCount k w

/-
============================================================================
§ 1. Basic properties of the Collatz step
============================================================================

The Collatz step of an even number is n/2.
-/
theorem step_even {n : ℕ} (h : Even n) : step n = n / 2 := by
  exact if_pos ( Nat.even_iff.mp h )

/-
The Collatz step of an odd number is 3n+1.
-/
theorem step_odd {n : ℕ} (h : Odd n) : step n = 3 * n + 1 := by
  exact if_neg ( by obtain ⟨ k, rfl ⟩ := h; norm_num )

/-
After an odd Collatz step, the result is always even.
    This is because 3n+1 is even whenever n is odd.
-/
theorem step_odd_result_even {n : ℕ} (h : Odd n) : Even (step n) := by
  rcases h with ⟨ k, rfl ⟩ ; simp +decide [ step, parity_simps ] ;

/-
============================================================================
§ 2. Congruence preservation — the key structural lemma
============================================================================

The Collatz step preserves congruences with halved modulus.
    If n ≡ m (mod 2M) with M > 0, then n and m have the same parity,
    and step(n) ≡ step(m) (mod M). This is the engine of the cylinder theory.
-/
theorem step_congr_mod (n m M : ℕ) (hM : 0 < M)
    (h : n % (2 * M) = m % (2 * M)) :
    n % 2 = m % 2 ∧ step n % M = step m % M := by
  unfold step;
  split_ifs <;> simp_all +decide [ Nat.mod_eq_of_lt ];
  · rw [ ← Nat.mod_add_div n ( 2 * M ), ← Nat.mod_add_div m ( 2 * M ), h ];
    norm_num [ Nat.add_div, Nat.mul_div_assoc, hM ];
    norm_num [ Nat.add_mod, Nat.mul_mod, Nat.mul_div_assoc, hM ];
    norm_num [ mul_assoc, Nat.mul_div_assoc, hM ];
  · have := congr_arg ( · % 2 ) h; norm_num [ Nat.add_mod, Nat.mul_mod, ‹n % 2 = 0›, ‹m % 2 = 1› ] at this;
  · have := congr_arg ( · % 2 ) h; norm_num [ Nat.add_mod, Nat.mul_mod, ‹n % 2 = _›, ‹m % 2 = _› ] at this;
  · exact Nat.ModEq.add ( Nat.ModEq.mul_left _ <| Nat.ModEq.of_dvd ( dvd_mul_left _ _ ) h ) rfl

/-
============================================================================
§ 3. Parity word depends only on residue class — Main Theorem A
============================================================================

**Theorem A (Parity Cylinder Classification).**
    The length-k parity word depends only on n mod 2^k.
    This means each residue class modulo 2^k determines a unique parity profile,
    establishing an exact correspondence between arithmetic cylinders and
    symbolic orbit prefixes.
-/
theorem parityWord_determined_by_residue (k : ℕ) (n m : ℕ)
    (h : n % 2 ^ k = m % 2 ^ k) :
    parityWord k n = parityWord k m := by
  -- By induction on $j$, we show that for all $j \leq k$, $step^[j] n \equiv step^[j] m \pmod{2^{k-j}}$.
  have h_ind : ∀ j ≤ k, step^[j] n % 2^(k-j) = step^[j] m % 2^(k-j) := by
    intro j hj;
    induction' j with j ih;
    · exact h;
    · have := step_congr_mod ( step^[j] n ) ( step^[j] m ) ( 2 ^ ( k - j - 1 ) ) ?_ ?_;
      · simpa only [ Function.iterate_succ_apply' ] using this.2;
      · positivity;
      · convert ih ( Nat.le_of_succ_le hj ) using 1 <;> rw [ ← pow_succ', Nat.sub_add_cancel ( Nat.sub_pos_of_lt hj ) ];
  funext i;
  have := h_ind i.val ( Nat.le_of_lt i.2 ) ; simp_all +decide [ Nat.even_iff, parityWord ] ;
  rw [ Nat.odd_iff, Nat.odd_iff, ← Nat.mod_mod_of_dvd _ ( dvd_pow_self _ ( Nat.sub_ne_zero_of_lt i.2 ) ), ← Nat.mod_mod_of_dvd _ ( dvd_pow_self _ ( Nat.sub_ne_zero_of_lt i.2 ) ), h_ind _ ( Nat.le_of_lt i.2 ) ];
  norm_num [ Nat.mod_mod_of_dvd _ ( dvd_pow_self _ ( Nat.sub_ne_zero_of_lt i.2 ) ) ]

/-
============================================================================
§ 4. No consecutive odd parities — structural constraint on words
============================================================================

In any realized parity word, an odd entry is always followed by an even entry.
    This reflects that 3n+1 is always even for odd n.
-/
theorem no_consecutive_odd_parities (n : ℕ) (k : ℕ) (i : Fin k)
    (hi : i.val + 1 < k)
    (hodd : parityWord k n i = true) :
    parityWord k n ⟨i.val + 1, hi⟩ = false := by
  unfold parityWord at hodd ⊢;
  simp_all +decide [ Function.iterate_succ_apply', step ];
  grind

/-
============================================================================
§ 5. Residue class counting — Theorem B
============================================================================

**Theorem B (Residue Class Upper Bound).**
    The count of elements in {0, ..., N} belonging to a residue class mod M
    is at most ⌊N/M⌋ + 1.
-/
theorem residue_count_upper (N M a : ℕ) (hM : 0 < M) (ha : a < M) :
    ((Finset.range (N + 1)).filter (fun n => n % M = a)).card ≤ N / M + 1 := by
  -- The elements of {0,...,N} with n % M = a form an arithmetic progression: a, a+M, a+2M, ..., such that they do not exceed N.
  have h_arith_prog : Finset.filter (fun n => n % M = a) (Finset.range (N + 1)) ⊆ Finset.image (fun k => a + k * M) (Finset.range (N / M + 1)) := by
    intro n hn; simp_all +decide [ Nat.mod_eq_of_lt ] ;
    exact ⟨ n / M, Nat.div_le_div_right hn.1, by linarith [ Nat.mod_add_div n M ] ⟩;
  exact le_trans ( Finset.card_le_card h_arith_prog ) ( Finset.card_image_le.trans ( by norm_num ) )

/-
**Theorem B (Residue Class Lower Bound).**
    The count of elements in {0, ..., N} belonging to a residue class mod M
    is at least (N + 1) / M. Here (N+1)/M is natural division (floor).
-/
theorem residue_count_lower (N M a : ℕ) (hM : 0 < M) (ha : a < M) (hN : a ≤ N) :
    (N + 1) / M ≤ ((Finset.range (N + 1)).filter (fun n => n % M = a)).card := by
  -- The set {a + j*M | j < (N+1)/M} is a subset of {n ∈ Finset.range (N + 1) | n % M = a}.
  have h_subset : Finset.image (fun j => a + j * M) (Finset.range ((N + 1) / M)) ⊆ Finset.filter (fun n => n % M = a) (Finset.range (N + 1)) := by
    intro x hx; obtain ⟨ j, hj, rfl ⟩ := Finset.mem_image.mp hx; simp_all +decide [ Nat.mod_eq_of_lt ] ;
    nlinarith [ Nat.div_mul_le_self ( N + 1 ) M ];
  exact le_trans ( by rw [ Finset.card_image_of_injective ] <;> aesop_cat ) ( Finset.card_mono h_subset )

/-
============================================================================
§ 6. Odd count + Even count = k
============================================================================

The number of odd and even entries in a length-k word sum to k.
-/
theorem oddCount_add_evenCount (k : ℕ) (w : Fin k → Bool) :
    oddCount k w + evenCount k w = k := by
  convert Finset.card_add_card_compl ( Finset.filter ( fun i => w i = true ) ( Finset.univ ( α := Fin k ) ) ) using 1 ; aesop;
  norm_num

/-
============================================================================
§ 7. Affine coefficient structure
============================================================================

The D coefficient of the affine formula is always positive.
-/
theorem affineCoeffs_D_pos (k : ℕ) (w : Fin k → Bool) :
    0 < (affineCoeffs k w).2.2 := by
  induction' k with k ih;
  · exact zero_lt_one;
  · exact if h : w ⟨ k, by linarith ⟩ then by rw [ affineCoeffs ] ; exact by aesop else by rw [ affineCoeffs ] ; exact by aesop;

/-
The A coefficient of the affine formula is always positive.
-/
theorem affineCoeffs_A_pos (k : ℕ) (w : Fin k → Bool) :
    0 < (affineCoeffs k w).1 := by
  induction' k with k ih;
  · decide +revert;
  · by_cases h : w ⟨ k, Nat.lt_succ_self k ⟩ <;> simp_all +decide [ affineCoeffs ]

end Collatz