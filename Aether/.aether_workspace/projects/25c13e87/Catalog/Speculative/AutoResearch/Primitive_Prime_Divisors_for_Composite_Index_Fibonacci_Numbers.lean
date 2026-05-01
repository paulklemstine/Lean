import Mathlib

/-! # Helper lemmas for Carmichael's theorem -/

set_option maxHeartbeats 800000

-- F(a)*F(b) ≤ F(a+b) for a, b ≥ 1
lemma fib_mul_le (a b : ℕ) (ha : 1 ≤ a) (hb : 1 ≤ b) :
    Nat.fib a * Nat.fib b ≤ Nat.fib (a + b) := by
  cases a <;> cases b <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.fib_add ]

-- F(a)*F(b) < F(a+b) for a ≥ 2, b ≥ 2
lemma fib_mul_lt (a b : ℕ) (ha : 2 ≤ a) (hb : 2 ≤ b) :
    Nat.fib a * Nat.fib b < Nat.fib (a + b) := by
  induction' ha with a ha ih generalizing b
  · simp +arith +decide [ Nat.fib_add_two, add_comm ]
  · rw [ Nat.succ_add, Nat.fib_add ]
    nlinarith [ Nat.fib_pos.2 ( show 0 < a by linarith [ Nat.succ_le_iff.mp ha ] ),
                Nat.fib_pos.2 ( show 0 < b by linarith ),
                Nat.fib_mono ( Nat.le_succ b ) ]

-- F(a*b) > F(a) * F(b) for a ≥ 2, b ≥ 2
lemma fib_mul_lt' (a b : ℕ) (ha : 2 ≤ a) (hb : 2 ≤ b) :
    Nat.fib a * Nat.fib b < Nat.fib (a * b) := by
  rcases a with ( _ | _ | a ) <;> rcases b with ( _ | _ | b ) <;> simp_all +arith +decide
  exact fib_mul_lt ( a + 2 ) ( b + 2 ) ( by linarith ) ( by linarith ) |>
    fun h => by simpa only [ Nat.mul_succ, Nat.fib_add ] using
      h.trans_le ( Nat.fib_mono <| by nlinarith )

-- F(n) ≥ n for n ≥ 5
lemma fib_ge_id (n : ℕ) (hn : 5 ≤ n) : n ≤ Nat.fib n := by
  induction hn <;> simp_all +arith +decide [ Nat.fib_add_two ]
  rcases ‹5 ≤ _› with ( _ | _ | _ | _ | _ | m ) <;> simp_all +arith +decide [ Nat.fib_add_two ]
  grind

-- F(a) and F(b) are coprime when gcd(a, b) = 1
lemma fib_coprime_of_coprime (a b : ℕ) (h : Nat.Coprime a b) :
    Nat.Coprime (Nat.fib a) (Nat.fib b) := by
  rw [ Nat.Coprime, Nat.gcd_comm ] at h ⊢
  rw [ ← Nat.fib_gcd, h, Nat.fib_one ]

-- F(n) divides F(n*k)
lemma fib_div_fib_dvd (n k : ℕ) : Nat.fib n ∣ Nat.fib (n * k) :=
  Nat.fib_dvd _ _ (dvd_mul_right _ _)

-- F(n*k+1) ≡ F(n+1)^k mod p when p | F(n)
lemma fib_succ_mul_mod (n k : ℕ) (p : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n) :
    (Nat.fib (n * k + 1) : ZMod p) = (Nat.fib (n + 1) : ZMod p) ^ k := by
  haveI := Fact.mk hp
  norm_num [ ← ZMod.natCast_eq_zero_iff ] at *
  induction k <;> simp_all +decide [ Nat.fib_add, pow_succ', Nat.mul_succ ]
  ring

-- F(n*k)/F(n) ≡ k * F(n+1)^(k-1) mod p when p | F(n)
lemma fib_div_mod (n k : ℕ) (p : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n)
    (hn : 0 < n) (hk : 0 < k) :
    (Nat.fib (n * k) / Nat.fib n : ZMod p) =
      (k : ZMod p) * (Nat.fib (n + 1) : ZMod p) ^ (k - 1) := by
  induction' k with k ih
  · contradiction
  · have h_ind : (Nat.fib (n * (k + 1)) : ℤ) =
        (Nat.fib (n * k) : ℤ) * (Nat.fib (n - 1) : ℤ) +
        (Nat.fib (n * k + 1) : ℤ) * (Nat.fib n : ℤ) := by
      rcases n <;> simp_all +decide [ Nat.fib_add_two, Nat.mul_succ ]
      norm_cast; convert Nat.fib_add _ _ using 1
    have h_div : (Nat.fib (n * (k + 1)) / Nat.fib n : ℤ) =
        (Nat.fib (n * k) / Nat.fib n : ℤ) * (Nat.fib (n - 1) : ℤ) +
        (Nat.fib (n * k + 1) : ℤ) := by
      rw [ Int.ediv_eq_of_eq_mul_left ]
      · aesop
      · rw [ add_mul, mul_right_comm, Int.ediv_mul_cancel ]
        · convert h_ind using 1
        · exact_mod_cast fib_div_fib_dvd n k
    have h_ind_step :
        (Nat.fib (n * k) / Nat.fib n : ZMod p) * (Nat.fib (n - 1) : ZMod p) +
          (Nat.fib (n * k + 1) : ZMod p) =
        (k * (Nat.fib (n + 1) : ZMod p) ^ (k - 1)) * (Nat.fib (n + 1) : ZMod p) +
          (Nat.fib (n + 1) : ZMod p) ^ k := by
      have h1 : (Nat.fib (n * k + 1) : ZMod p) = (Nat.fib (n + 1) : ZMod p) ^ k :=
        fib_succ_mul_mod n k p hp hpn
      rcases k with ( _ | k ) <;> simp_all +decide [ pow_succ, mul_assoc ]
      cases n <;> simp_all +decide [ Nat.fib_add_two, ← ZMod.natCast_eq_zero_iff ]
    convert h_ind_step using 1
    · norm_cast at *; rw [h_div]
    · cases k <;> simp_all +decide [ pow_succ, add_mul ] ; ring

-- Weak Wall's: p ∤ F(n*k)/F(n) when p | F(n) and p ∤ k
lemma weak_wall (n k p : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n)
    (hpk : ¬(p ∣ k)) (hn : 0 < n) (hk : 0 < k) :
    ¬(p ∣ (Nat.fib (n * k) / Nat.fib n)) := by
  have h_mod := fib_div_mod n k p hp hpn hn hk
  haveI := Fact.mk hp
  simp_all +decide [ ← ZMod.natCast_eq_zero_iff ]
  intro h
  have := Nat.fib_coprime_fib_succ n
  simp_all +decide [ ← ZMod.natCast_eq_zero_iff ]
  exact absurd (Nat.dvd_gcd
    (show p ∣ Nat.fib n from by rwa [← ZMod.natCast_eq_zero_iff])
    (show p ∣ Nat.fib (n + 1) from by rwa [← ZMod.natCast_eq_zero_iff]))
    (by aesop)

-- Wall base case: v_p(F(np)/F(n)) = 1 for odd prime p | F(n)
lemma wall_base (n p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (hpn : p ∣ Nat.fib n) (hn : 2 ≤ n) :
    padicValNat p (Nat.fib (n * p) / Nat.fib n) = 1 := by
  sorry

/-- Wall's theorem: v_p(F(n*k)) = v_p(F(n)) + v_p(k) for odd prime p | F(n). -/
lemma wall_theorem (n k p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n) (hk : 0 < k) :
    padicValNat p (Nat.fib (n * k)) = padicValNat p (Nat.fib n) + padicValNat p k := by
  sorry
