import Mathlib

/-! # CatalogBuild.Computation.Factoring.PhaseIIFormal

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 20
-/

noncomputable section

/-- Smooth numbers are upward-closed in the smoothness parameter:
B-smooth implies B'-smooth for B ≤ B'. -/
theorem isSmooth_mono {B B' n : ℕ} (hBB : B ≤ B') (hn : IsSmooth B n) :
    IsSmooth B' n := by
  intro p hp hpd
  exact le_trans (hn p hp hpd) hBB

/-- Any divisor of a B-smooth number is B-smooth. -/
theorem isSmooth_of_dvd {B n d : ℕ} (hn : IsSmooth B n) (hd : d ∣ n) (hn0 : n ≠ 0) :
    IsSmooth B d := by
  intro p hp hpd
  exact hn p hp (dvd_trans hpd hd)

/-- Prime numbers are self-smooth: p is p-smooth. -/
theorem prime_isSmooth_self {p : ℕ} (hp : p.Prime) : IsSmooth p p := by
  intro q hq hqp
  exact le_of_eq (hp.eq_one_or_self_of_dvd q hqp |>.resolve_left hq.one_lt.ne')

/-- The Dickman function on [0, 2]: ρ(u) = 1 for u ∈ (0,1], ρ(u) = 1 - ln(u) for u ∈ (1,2]. -/
noncomputable def dickmanOnePiece (u : ℝ) : ℝ :=
  if u ≤ 0 then 0
  else if u ≤ 1 then 1
  else if u ≤ 2 then 1 - Real.log u
  else 0  -- placeholder for higher values

/-- ρ(1) = 1. -/
theorem dickman_one : dickmanOnePiece 1 = 1 := by
  simp [dickmanOnePiece]

/-- ρ(u) = 1 for u ∈ (0, 1]. -/
theorem dickman_unit_interval {u : ℝ} (hu0 : 0 < u) (hu1 : u ≤ 1) :
    dickmanOnePiece u = 1 := by
  unfold dickmanOnePiece
  simp [not_le.mpr hu0, hu1]

/-- ρ(2) = 1 - ln 2. -/
theorem dickman_two : dickmanOnePiece 2 = 1 - Real.log 2 := by
  unfold dickmanOnePiece
  norm_num

/-- The L-notation complexity function. -/
noncomputable def Lnotation (N : ℝ) (α c : ℝ) : ℝ :=
  Real.exp (c * (Real.log N) ^ α * (Real.log (Real.log N)) ^ (1 - α))

/-- L_N[1, c] = exp(c · ln N) = N^c — polynomial in N. -/
theorem Lnotation_one (N c : ℝ) :
    Lnotation N 1 c = Real.exp (c * Real.log N) := by
  unfold Lnotation
  simp [rpow_one, rpow_zero]

/-- The MLC(k) search space after applying k independent lenses. -/
def mlcReduction (S k : ℕ) : ℕ := S / 2 ^ k

/-- MLC composition law: (S / 2^a) / 2^b = S / 2^{a+b}.
This is the "power law" establishing the monoid structure. -/
theorem mlc_composition (S a b : ℕ) :
    mlcReduction (mlcReduction S a) b = mlcReduction S (a + b) := by
  simp [mlcReduction, Nat.div_div_eq_div_mul, pow_add]

/-- MLC commutativity: order of lens application doesn't matter. -/
theorem mlc_comm (S a b : ℕ) :
    mlcReduction (mlcReduction S a) b = mlcReduction (mlcReduction S b) a := by
  rw [mlc_composition, mlc_composition, Nat.add_comm]

/-- After ⌊log₂ S⌋ + 1 lenses, the search space reaches 0. -/
theorem mlc_max_lenses (S k : ℕ) (hk : S < 2 ^ k) :
    mlcReduction S k = 0 := by
  simp only [mlcReduction]
  exact Nat.div_eq_of_lt hk

/-- The quantum speedup: √(S/512) ≤ √S for all S. -/
theorem quantum_savings (S : ℕ) :
    Nat.sqrt (S / 512) ≤ Nat.sqrt S := by
  exact Nat.sqrt_le_sqrt (Nat.div_le_self S 512)

/-- Tropical additivity: v_p(a · b) = v_p(a) + v_p(b). -/
theorem tropical_additivity (p a b : ℕ) (ha : a ≠ 0) (hb : b ≠ 0) :
    (a * b).factorization p = a.factorization p + b.factorization p := by
  simp [Nat.factorization_mul ha hb]

/-- For a semiprime N = p * q with distinct primes,
the tropical profile at p is exactly 1. -/
theorem semiprime_tropical_profile (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (p * q).factorization p = 1 := by
  rw [Nat.factorization_mul hp.ne_zero hq.ne_zero]
  simp [hp.factorization, hq.factorization, Finsupp.single_eq_of_ne' (Ne.symm hpq)]

/-- Tropical factorization constraint: any factorization N = a * b
splits the tropical profile additively at every prime. -/
theorem tropical_constraint (N a b ℓ : ℕ) (ha : a ≠ 0) (hb : b ≠ 0) (hN : N = a * b) :
    N.factorization ℓ = a.factorization ℓ + b.factorization ℓ := by
  subst hN
  exact tropical_additivity ℓ a b ha hb

/-- [Section: # CatalogBuild.Computation.Factoring.PhaseIIFormal
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 20] -/
theorem orbit_periodicity {n : ℕ} (hn : 0 < n) (f : Fin n → Fin n) (x : Fin n) :
    ∃ i j : ℕ, i < j ∧ j ≤ n ∧ f^[i] x = f^[j] x := by
  by_contra! h;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] x ) ( Finset.Iic n ) ) ) ( by rw [ Finset.card_image_of_injOn ( fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h _ _ hi' ( by aesop ) hij.symm ) ( not_lt.mp fun hj' => h _ _ hj' ( by aesop ) hij ) ) ] ; simpa )

/-- [Section: # CatalogBuild.Computation.Factoring.PhaseIIFormal
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 20] -/
theorem fib_lt_pow_two (n : ℕ) (hn : 2 ≤ n) : Nat.fib (n + 2) < 2 ^ n := by
  induction hn <;> simp_all +arith +decide [ Nat.fib_add_two, pow_succ' ];
  grind

theorem tribonacci_lt_pow_two (n : ℕ) (hn : 1 ≤ n) : tribonacci n < 2 ^ n := by
  rcases n with _ | _ | _ | n <;> norm_num [ * ] at *;
  · decide +revert;
  · decide +revert;
  · induction n <;> norm_num [ pow_succ, tribonacci ] at *;
    grind

end
