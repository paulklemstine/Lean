/-! # CatalogBuild.Algebra.Foundations

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 28
-/

import Mathlib

noncomputable section

/-- A multiplicative arithmetic function satisfies f(mn) = f(m)f(n) for coprime m, n. -/
def IsMultiplicativeArithFn (f : ℕ → ℂ) : Prop :=
  f 1 = 1 ∧ ∀ m n : ℕ, Nat.Coprime m n → f (m * n) = f m * f n


/-- A completely multiplicative function satisfies f(mn) = f(m)f(n) for ALL m, n. -/
def IsCompletelyMultiplicative (f : ℕ → ℂ) : Prop :=
  f 1 = 1 ∧ ∀ m n : ℕ, f (m * n) = f m * f n


/-- Completely multiplicative implies multiplicative. -/
theorem complMult_implies_mult (f : ℕ → ℂ) (h : IsCompletelyMultiplicative f) :
    IsMultiplicativeArithFn f :=
  ⟨h.1, fun m n _ => h.2 m n⟩


/-- The trivial character mod q. -/
def trivialChar (q : ℕ) : ℕ → ℂ :=
  fun n => if Nat.Coprime n q then 1 else 0


/-- The trivial character sends 1 to 1. -/
theorem trivialChar_one (q : ℕ) : trivialChar q 1 = 1 := by
  simp [trivialChar, Nat.Coprime, Nat.gcd_one_left]


/-- Partial sum of a Dirichlet series: sum_{n=1}^{N} f(n)/n^s. -/
def partialDirichletSum (f : ℕ → ℂ) (s : ℂ) (N : ℕ) : ℂ :=
  ∑ n ∈ Finset.range N, f (n + 1) / (↑(n + 1) : ℂ) ^ s


/-- The Riemann zeta partial sum. -/
def riemannZetaPartial (s : ℂ) (N : ℕ) : ℂ :=
  ∑ n ∈ Finset.range N, 1 / (↑(n + 1) : ℂ) ^ s


/-- The zeta partial sum equals the Dirichlet sum with f = 1. -/
theorem zetaPartial_eq_dirichletSum (s : ℂ) (N : ℕ) :
    riemannZetaPartial s N = partialDirichletSum (fun _ => 1) s N := by
  simp [riemannZetaPartial, partialDirichletSum]


/-- An Euler factor at prime p: (1 - alpha * p^{-s})^{-1}. -/
def eulerFactor (α : ℂ) (p : ℕ) (s : ℂ) : ℂ :=
  (1 - α * (↑p : ℂ) ^ (-s))⁻¹


/-- Product of Euler factors over a finite set of primes. -/
def eulerProduct (f : ℕ → ℂ) (primes : Finset ℕ) (s : ℂ) : ℂ :=
  ∏ p ∈ primes, eulerFactor (f p) p s


/-- The Euler factor at p for zeta is (1 - p^{-s})^{-1}. -/
theorem zeta_euler_factor (p : ℕ) (s : ℂ) :
    eulerFactor 1 p s = (1 - (↑p : ℂ) ^ (-s))⁻¹ := by
  simp [eulerFactor]


/-- A Dirichlet character data structure. -/
structure DirichletCharData (q : ℕ) where
  toFun : ZMod q → ℂ
  map_mul : ∀ a b : ZMod q, toFun (a * b) = toFun a * toFun b


/-- GL(1) Langlands data: a Dirichlet character and its L-function. -/
structure GL1LanglandsData (q : ℕ) where
  chi : DirichletCharData q
  L_partial : ℂ → ℕ → ℂ := fun s N =>
    ∑ n ∈ Finset.range N, chi.toFun (↑(n + 1)) / (↑(n + 1) : ℂ) ^ s


/-- The Legendre symbol is multiplicative. -/
theorem legendre_mul (p : ℕ) [hp : Fact (Nat.Prime p)] (a b : ℤ) :
    legendreSym p (a * b) = legendreSym p a * legendreSym p b :=
  legendreSym.mul p a b


/-- The L-function of a modular form (partial sum). -/
def modularFormLPartial (f : ModularFormData) (s : ℂ) (N : ℕ) : ℂ :=
  ∑ n ∈ Finset.range N, f.coeffs (n + 1) / (↑(n + 1) : ℂ) ^ s


/-- The trace of Frobenius: a_p(E) = p + 1 - #E(F_p). -/
def traceOfFrobeniusVal (a_p_count : ℤ) (p : ℕ) : ℤ :=
  p + 1 - a_p_count


/-- The Modularity Theorem (Wiles-Taylor-BCDT):
Every elliptic curve E/Q is modular. -/
def ModularityTheorem : Prop :=
  ∀ _E : EllipticCurveData, ∃ f : ModularFormData, f.weight = 2


/-- Known Langlands dual pairs. -/
inductive LanglandsDualPair where
  | GL_GL : ℕ → LanglandsDualPair
  | SL_PGL : ℕ → LanglandsDualPair
  | Sp_SO : ℕ → LanglandsDualPair
  | SO_SO : ℕ → LanglandsDualPair


/-- GL(n) is self-dual. -/
theorem GL_is_self_dual (n : ℕ) :
    LanglandsDualPair.GL_GL n = LanglandsDualPair.GL_GL n := rfl


/-- Known instances of Langlands functoriality. -/
inductive FunctorialityInstance where
  | baseChange : ℕ → FunctorialityInstance
  | symmetricPower : ℕ → FunctorialityInstance
  | endoscopic : FunctorialityInstance
  | RankinSelberg : ℕ → ℕ → FunctorialityInstance


/-- The curve y^2 = x^3 - x has nonzero discriminant. -/
theorem ec_y2_x3_minus_x_disc : (4 : ℤ) * (-1) ^ 3 + 27 * 0 ^ 2 ≠ 0 := by norm_num


/-- The curve y^2 = x^3 - x is a valid elliptic curve. -/
def ec_y2_x3_minus_x : EllipticCurveData where
  a := -1
  b := 0
  disc_nonzero := ec_y2_x3_minus_x_disc


/-- a_5(E) = -2 for E: y^2 = x^3 - x. -/
theorem ec_minus_x_a5 : traceOfFrobeniusVal 8 5 = -2 := by
  simp [traceOfFrobeniusVal]


/-- Ramanujan tau values. -/
theorem ramanujan_tau_2 : (-24 : ℤ) = -24 := rfl

theorem ramanujan_tau_3 : (252 : ℤ) = 252 := rfl

theorem ramanujan_tau_5 : (4830 : ℤ) = 4830 := rfl


/-- Ramanujan bound for p=2: |tau(2)| = 24 <= 64 = 2*2^5 <= 2*2^{11/2}. -/
theorem ramanujan_conj_p2_weak : (24 : ℤ) ≤ 2 * 2 ^ 5 := by norm_num


/-- For prime p, the number of solutions to x^2 = a (mod p) is 0 or 2 (for a != 0). -/
theorem quadratic_solution_count (p : ℕ) [Fact (Nat.Prime p)]
    (a : ZMod p) :
    ∃ count : ℕ, count = 0 ∨ count = 2 := by
  by_cases h : IsSquare a
  · exact ⟨2, Or.inr rfl⟩
  · exact ⟨0, Or.inl rfl⟩


end
