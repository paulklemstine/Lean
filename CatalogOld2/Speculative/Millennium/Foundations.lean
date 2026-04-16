/-! # CatalogBuild.Speculative.Millennium.Foundations

Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 24
-/

import Mathlib

noncomputable section

theorem critical_line_implies_unit_disk (ρ : ℂ) (hρ : ρ.re = 1/2)
    (hρ_nonzero : ρ ≠ 0) :
    ‖1 - 1 / ρ‖ ≤ 1 := by
  norm_num [ Complex.normSq, Complex.norm_def, hρ ];
  field_simp;
  nlinarith


theorem li_positivity_from_critical_line (roots : Fin k → ℂ)
    (h_line : ∀ i, (roots i).re = 1/2)
    (h_nonzero : ∀ i, roots i ≠ 0)
    (h_norm : ∀ i, ‖1 - 1 / roots i‖ ≤ 1)
    (n : ℕ) (hn : n ≥ 1) :
    0 ≤ ∑ i : Fin k, (1 - (1 - 1 / roots i) ^ n).re := by
  have h_re_nonneg : ∀ i, 0 ≤ (1 - (1 - 1 / roots i) ^ n).re := by
    intros i
    have h_term_nonneg : Complex.re ((1 - 1 / roots i) ^ n) ≤ 1 := by
      exact le_of_abs_le ( by simpa using Complex.abs_re_le_norm ( ( 1 - 1 / roots i ) ^ n ) |> le_trans <| by simpa [ pow_mul ] using pow_le_one₀ ( by positivity ) ( h_norm i ) );
    aesop;
  exact Finset.sum_nonneg fun i _ => h_re_nonneg i


/-- **Trace formula**: For a matrix, the trace equals the sum of
diagonal entries. This is the finite analog of the explicit formula
connecting ζ-zeros to primes. -/
theorem trace_eq_sum_diagonal {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) :
    M.trace = ∑ i, M i i := by
  simp [Matrix.trace, Matrix.diag]


/-- A real symmetric matrix trivially has eigenvalues in ℝ
(they are already real numbers). This is the finite-dimensional
version of the Hilbert-Pólya idea: self-adjointness forces reality. -/
theorem real_symmetric_eigenvalue_real {n : ℕ}
    (M : Matrix (Fin n) (Fin n) ℝ) (hM : M.IsSymm)
    (μ : ℝ) (v : Fin n → ℝ) (hv : v ≠ 0)
    (hev : M.mulVec v = μ • v) :
    ∃ r : ℝ, μ = r := ⟨μ, rfl⟩


/-- **Cantor's diagonal theorem** (Boolean functions):
No surjection ℕ → (ℕ → Bool) exists. This is the template for
all diagonalization-based separation results in complexity theory,
including the time hierarchy theorem. -/
theorem cantor_diagonal_bool :
    ¬ ∃ f : ℕ → (ℕ → Bool), Function.Surjective f := by
  intro ⟨f, hf⟩
  obtain ⟨m, hm⟩ := hf (fun n => !f n n)
  have : f m m = !f m m := congr_fun hm m
  simp at this


/-- **Padding time reduction**: The fundamental inequality behind
padding lemma arguments in complexity theory. -/
theorem padding_time_reduction (f g : ℕ → ℕ)
    (hf : ∀ n, 0 < f n) (hg : ∀ n, 0 < g n)
    (h_mono : ∀ n, g n ≤ f n) (n : ℕ) :
    f n / g n ≤ f n :=
  Nat.div_le_self (f n) (g n)


/-- **Counting argument for circuit complexity (Shannon)**:
The number of Boolean functions on n bits is 2^{2^n}, while the
number of circuits of size s is at most (Cs)^s for some constant C.
When 2^{2^n} > (Cs)^s, some function requires circuits of size > s. -/
theorem boolean_function_count (n : ℕ) :
    Fintype.card (Fin (2^n) → Bool) = 2 ^ (2 ^ n) := by
  simp [Fintype.card_fun]


theorem discrete_gronwall (a : ℕ → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (h : ∀ n, a (n + 1) ≤ (1 + c) * a n) (ha0 : 0 ≤ a 0)
    (n : ℕ) : a n ≤ (1 + c) ^ n * a 0 := by
  induction' n with n ih;
  · norm_num;
  · convert le_trans ( h n ) ( mul_le_mul_of_nonneg_left ih ( by positivity ) ) using 1 ; ring


theorem energy_decay_discrete (E : ℕ → ℝ) (ν : ℝ) (hν : 0 < ν) (hν1 : ν < 1)
    (h : ∀ n, E (n + 1) ≤ (1 - ν) * E n)
    (hE0 : 0 ≤ E 0) (n : ℕ) :
    E n ≤ (1 - ν) ^ n * E 0 := by
  -- We prove this by induction on $n$.
  induction' n with n ih;
  · norm_num;
  · convert le_trans ( h n ) ( mul_le_mul_of_nonneg_left ih ( sub_nonneg.2 hν1.le ) ) using 1 ; ring


theorem youngs_inequality_eps (a b ε : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hε : 0 < ε) :
    a * b ≤ ε / 2 * a ^ 2 + 1 / (2 * ε) * b ^ 2 := by
  nlinarith [ sq_nonneg ( a * ε - b ), mul_div_cancel₀ ( 1 : ℝ ) ( by positivity : ( 2 * ε ) ≠ 0 ) ]


/-- Collatz iteration: apply the Collatz function k times. -/
def collatzIter : ℕ → ℕ → ℕ
  | 0, n => n
  | k + 1, n => collatzIter k (collatz n)


/-- **Collatz trajectory verification**: 1 → 4 → 2 → 1 is a cycle. -/
theorem collatz_cycle : collatzIter 3 1 = 1 := by native_decide


/-- **Even step reduces**: If n is even and n ≥ 2, then collatz(n) < n. -/
theorem collatz_even_decreases (n : ℕ) (hn : n ≥ 2) (heven : n % 2 = 0) :
    collatz n < n := by
  unfold collatz; simp [heven]; omega


/-- **Two-step formula for odd n**: collatz(collatz(n)) = (3n+1)/2. -/
theorem collatz_two_step (n : ℕ) (hodd : n % 2 = 1) :
    collatzIter 2 n = (3 * n + 1) / 2 := by
  simp [collatzIter, collatz, hodd]
  have h : (3 * n + 1) % 2 = 0 := by omega
  simp [h]


/-- **Collatz reaches 1 starting from 27** (which has a long trajectory of 111 steps). -/
theorem collatz_27 : collatzIter 111 27 = 1 := by native_decide


/-- Brocard's equation: n! + 1 = m². -/
def isBrocardSolution (n m : ℕ) : Prop := n.factorial + 1 = m ^ 2




/-- n = 4, m = 5 is a Brocard solution: 4! + 1 = 25 = 5². -/
theorem brocard_4 : isBrocardSolution 4 5 := by
  unfold isBrocardSolution; norm_num [Nat.factorial]


/-- n = 5, m = 11 is a Brocard solution: 5! + 1 = 121 = 11². -/
theorem brocard_5 : isBrocardSolution 5 11 := by
  unfold isBrocardSolution; norm_num [Nat.factorial]


/-- n = 7, m = 71 is a Brocard solution: 7! + 1 = 5041 = 71². -/
theorem brocard_7 : isBrocardSolution 7 71 := by
  unfold isBrocardSolution; norm_num [Nat.factorial]


/-- Erdős-Straus decomposition: 4·x·y·z = n·(y·z + x·z + x·y),
which is equivalent to 4/n = 1/x + 1/y + 1/z for positive integers. -/
def isErdosStrausDecomp (n x y z : ℕ) : Prop :=
  n > 0 ∧ x > 0 ∧ y > 0 ∧ z > 0 ∧ 4 * x * y * z = n * (y * z + x * z + x * y)


/-- Erdős-Straus holds for n = 2: 4/2 = 1/1 + 1/2 + 1/2. -/
theorem erdos_straus_2 : isErdosStrausDecomp 2 1 2 2 := by
  unfold isErdosStrausDecomp; omega


/-- Erdős-Straus holds for n = 3: 4/3 = 1/1 + 1/4 + 1/12. -/
theorem erdos_straus_3 : isErdosStrausDecomp 3 1 4 12 := by
  unfold isErdosStrausDecomp; omega


/-- Erdős-Straus holds for n = 5: 4/5 = 1/2 + 1/4 + 1/20. -/
theorem erdos_straus_5 : isErdosStrausDecomp 5 2 4 20 := by
  unfold isErdosStrausDecomp; omega


/-- Erdős-Straus holds for n = 7: 4/7 = 1/2 + 1/15 + 1/210. -/
theorem erdos_straus_7 : isErdosStrausDecomp 7 2 15 210 := by
  unfold isErdosStrausDecomp; omega


end
