import Mathlib

namespace AntiGravity

/-- The support of `N` with respect to a divisor `d` is `N / d`. -/
def support (N d : ℕ) : ℕ := N / d

/-- The proof cost of `d` is the number of prime factors (with multiplicity). -/
def proofCost (d : ℕ) : ℕ := d.primeFactorsList.length

@[simp] theorem support_eq_div (N d : ℕ) : support N d = N / d := rfl

/-- For a list of naturals all at least `2`, `2 ^ length ≤ prod`. -/
lemma two_pow_length_le_prod_of_forall_two_le (l : List ℕ)
    (h : ∀ x ∈ l, 2 ≤ x) : 2 ^ l.length ≤ l.prod := by
  induction l with
  | nil => simp
  | cons x xs ih =>
    have hx : 2 ≤ x := h x (List.mem_cons_self)
    have htail : ∀ y ∈ xs, 2 ≤ y := fun y hy => h y (List.mem_cons_of_mem x hy)
    have hih := ih htail
    simp only [List.length_cons, List.prod_cons, pow_succ]
    calc 2 ^ xs.length * 2 ≤ xs.prod * x := by
            apply Nat.mul_le_mul hih hx
      _ = x * xs.prod := by ring
  
/-- The central Ω-bound: `2 ^ proofCost d ≤ d`. -/
theorem two_pow_proofCost_le {d : ℕ} (hd : 0 < d) : 2 ^ proofCost d ≤ d := by
  unfold proofCost
  have h : ∀ x ∈ d.primeFactorsList, 2 ≤ x := by
    intro x hx
    exact (Nat.prime_of_mem_primeFactorsList hx).two_le
  have hle := two_pow_length_le_prod_of_forall_two_le d.primeFactorsList h
  rwa [Nat.prod_primeFactorsList hd.ne'] at hle

/-- Denominator-antitonicity for natural division. -/
lemma div_le_div_of_le_right {N a b : ℕ} (ha : 0 < a) (hab : a ≤ b) :
    N / b ≤ N / a := by
  apply Nat.le_div_iff_mul_le ha |>.2
  calc N / b * a ≤ N / b * b := Nat.mul_le_mul_left _ hab
    _ ≤ N := Nat.div_mul_le_self N b

/-- The anti-gravity support trade-off. -/
theorem support_le_div_two_pow {N d : ℕ} (hd : 0 < d) :
    support N d ≤ N / 2 ^ proofCost d := by
  unfold support
  exact div_le_div_of_le_right (pow_pos (by norm_num) _) (two_pow_proofCost_le hd)

end AntiGravity