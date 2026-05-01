import Mathlib

/-! # CatalogBuild.Speculative.Other.NewDirections

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 24
-/

/-- Fibonacci numbers (project-local to avoid collision). -/
def fib_local : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | n + 2 => fib_local (n + 1) + fib_local n

/-- A number is a sum of two squares. -/
def IsSumTwoSq (n : ℤ) : Prop := ∃ a b : ℤ, a ^ 2 + b ^ 2 = n

/-- [Section: # CatalogBuild.Speculative.Other.NewDirections
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 24] -/
theorem wilson_5' : 24 % 5 = 4 := by norm_num

/-- [Section: # CatalogBuild.Speculative.Other.NewDirections
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 24] -/
theorem wilson_7' : 720 % 7 = 6 := by norm_num

theorem wilson_11' : 3628800 % 11 = 10 := by norm_num

/-- Quadratic residues mod 5: {0, 1, 4}. -/
theorem qr_mod5' : ∀ a : ZMod 5, a ^ 2 ∈ ({0, 1, 4} : Set (ZMod 5)) := by decide

/-- Quadratic residues mod 7: {0, 1, 2, 4}. -/
theorem qr_mod7' : ∀ a : ZMod 7, a ^ 2 ∈ ({0, 1, 2, 4} : Set (ZMod 7)) := by decide

/-- The sum of the first n cubes equals the square of the triangular number. -/
theorem sum_cubes_eq_sq_sum (n : ℕ) :
    4 * ∑ i ∈ Finset.range n, (i + 1) ^ 3 = (n * (n + 1)) ^ 2 := by
  induction n with
  | zero => simp
  | succ n ih => simp [Finset.sum_range_succ]; nlinarith

/-- The sum of first n odd numbers is n². -/
theorem sum_odd_eq_sq (n : ℕ) :
    ∑ i ∈ Finset.range n, (2 * i + 1) = n ^ 2 := by
  induction n with
  | zero => simp
  | succ n ih => simp [Finset.sum_range_succ]; nlinarith

/-- Trace cyclicity for 2×2 matrices. -/
theorem trace_cyclic_2x2 (A B : Matrix (Fin 2) (Fin 2) ℤ) :
    Matrix.trace (A * B) = Matrix.trace (B * A) := by
  simp [Matrix.trace, Matrix.diag, Matrix.mul_apply, Fin.sum_univ_two]; ring

theorem cayley_hamilton_2x2 (A : Matrix (Fin 2) (Fin 2) ℤ) :
    A * A - (Matrix.trace A) • A + (Matrix.det A) • (1 : Matrix (Fin 2) (Fin 2) ℤ) = 0 := by
  ext i j ; fin_cases i <;> fin_cases j <;> simp +decide [ Matrix.mul_apply, Matrix.trace, Matrix.det_fin_two ] <;> ring;
  · erw [ show ( A 0 0 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => if i = 0 then A 0 0 else A 0 0 ) by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; erw [ show ( A 1 1 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => if i = 0 then A 1 1 else A 1 1 ) by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; erw [ show ( A 0 1 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => if i = 0 then A 0 1 else A 0 1 ) by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; erw [ show ( A 1 0 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => if i = 0 then A 1 0 else A 1 0 ) by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; norm_num ; ring;
  · ring!;
    erw [ show ( A 0 0 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) 0 1 = 0 by rfl ] ; ring;
  · erw [ show ( A 0 0 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) 1 0 = 0 from by trivial ] ; ring!;
  · ring!;
    aesop

/-- The matrix form of one CF step. -/
def cf_step_mat (a : ℤ) : Matrix (Fin 2) (Fin 2) ℤ := !![a, 1; 1, 0]

/-- det of a CF step is -1. -/
theorem det_cf_step_mat (a : ℤ) : Matrix.det (cf_step_mat a) = -1 := by
  simp [cf_step_mat, Matrix.det_fin_two]

/-- Two CF steps have det 1. -/
theorem det_two_cf_steps' (a b : ℤ) :
    Matrix.det (cf_step_mat a * cf_step_mat b) = 1 := by
  simp [Matrix.det_mul, det_cf_step_mat]

/-- The convergent [a; b] = !![a*b+1, a; b, 1]. -/
theorem cf_two_terms (a b : ℤ) :
    cf_step_mat a * cf_step_mat b = !![a * b + 1, a; b, 1] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [cf_step_mat, Matrix.mul_apply, Fin.sum_univ_two]

/-- In a k-regular graph on n vertices, n*k is even iff n or k is even. -/
theorem regular_graph_handshake (n k : ℕ) :
    Even (n * k) ↔ Even n ∨ Even k := by
  constructor
  · intro h; by_contra h'
    push_neg at h'
    exact (Nat.even_mul.mp h).elim h'.1 h'.2
  · intro h; exact Nat.even_mul.mpr h

/-- In a 4-regular graph, edges = 2n. -/
theorem four_regular_edges' (n : ℕ) : n * 4 / 2 = 2 * n := by omega

/-- Fermat's little theorem: a^p ≡ a (mod p) for small primes. -/
theorem fermat_little_3 : ∀ a : ZMod 3, a ^ 3 = a := by decide

theorem fermat_little_5 : ∀ a : ZMod 5, a ^ 5 = a := by decide

theorem fermat_little_7 : ∀ a : ZMod 7, a ^ 7 = a := by decide

/-- The norm form of ℤ[√2]: N(a + b√2) = a² - 2b². -/
def norm_sqrt2 (a b : ℤ) : ℤ := a ^ 2 - 2 * b ^ 2

/-- The norm is multiplicative. -/
theorem norm_sqrt2_mul (a₁ b₁ a₂ b₂ : ℤ) :
    norm_sqrt2 (a₁ * a₂ + 2 * b₁ * b₂) (a₁ * b₂ + b₁ * a₂) =
    norm_sqrt2 a₁ b₁ * norm_sqrt2 a₂ b₂ := by
  simp only [norm_sqrt2]; ring

/-- The fundamental solution to x² - 2y² = 1 is (3, 2). -/
theorem pell_sqrt2_fundamental : norm_sqrt2 3 2 = 1 := by decide

/-- The next Pell solution: (17, 12). -/
theorem pell_sqrt2_second : norm_sqrt2 17 12 = 1 := by decide

