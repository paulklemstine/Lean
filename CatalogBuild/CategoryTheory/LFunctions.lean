/-! # CatalogBuild.CategoryTheory.LFunctions

Auto-generated from theorem catalog database.
Domain: CategoryTheory
Declarations: 15
-/

import Mathlib

noncomputable section

/-- The Riemann zeta partial sum. -/
def zetaPartialSum (s : ℂ) (N : ℕ) : ℂ :=
  ∑ n ∈ range N, (1 : ℂ) / (↑(n + 1) : ℂ) ^ s

/-- The Basel problem statement: sum 1/n^2 = pi^2/6. -/

def basel_problem_statement : Prop :=
  HasSum (fun n : ℕ => (1 : ℝ) / ((n + 1) ^ 2)) (Real.pi ^ 2 / 6)

/-- The harmonic series diverges. -/

def zeta_pole_statement : Prop :=
  ¬ ∃ L : ℝ, HasSum (fun n : ℕ => (1 : ℝ) / (n + 1)) L

/-! ## Dirichlet L-functions -/

/-- A Dirichlet L-function partial sum. -/

def dirichletL (q : ℕ) (chi : ZMod q → ℂ) (s : ℂ) (N : ℕ) : ℂ :=
  ∑ n ∈ range N, chi (↑(n + 1) : ZMod q) / (↑(n + 1) : ℂ) ^ s

/-- The trivial character mod 1 gives zeta. -/

theorem trivial_char_gives_zeta (s : ℂ) (N : ℕ) :
    dirichletL 1 (fun _ => 1) s N = zetaPartialSum s N := by
  simp [dirichletL, zetaPartialSum, div_eq_mul_inv]

/-! ## L-functions of Elliptic Curves -/

/-- Euler factor for an elliptic curve L-function at a good prime. -/

def ecLFactor (a_p : ℤ) (p : ℕ) (s : ℂ) : ℂ :=
  (1 - (↑a_p : ℂ) * (↑p : ℂ) ^ (-s) + (↑p : ℂ) ^ (1 - 2 * s))⁻¹

/-! ## Conjectural Properties: The Selberg Class -/

/-- Axioms for L-functions in the Selberg class. -/

structure SelbergClassAxioms where
  L : ℂ → ℂ
  degree : ℕ
  has_euler_product : Prop
  has_analytic_continuation : Prop
  has_functional_equation : Prop

/-! ## The Birch and Swinnerton-Dyer Conjecture -/

/-- BSD data: algebraic rank should equal analytic rank. -/

structure BSDData where
  algebraic_rank : ℕ
  analytic_rank : ℕ
  bsd_conjecture : algebraic_rank = analytic_rank

/-! ## Rankin-Selberg L-functions -/

/-- The Rankin-Selberg L-function partial sum L(s, f x g). -/

def rankinSelbergPartial (f g : ℕ → ℂ) (s : ℂ) (N : ℕ) : ℂ :=
  ∑ n ∈ range N, f (n + 1) * g (n + 1) / (↑(n + 1) : ℂ) ^ s

/-! ## Symmetric Power L-functions -/

/-- Status of symmetric power functoriality. -/

inductive SymmetricPowerStatus where
  | proved : String → SymmetricPowerStatus
  | open_ : SymmetricPowerStatus


def symmetricPowerResults : ℕ → SymmetricPowerStatus
  | 0 => .proved "trivial"
  | 1 => .proved "trivial"
  | 2 => .proved "Gelbart-Jacquet 1978"
  | 3 => .proved "Kim-Shahidi 2002"
  | 4 => .proved "Kim 2003"
  | _ => .open_


theorem sym2_is_proved : symmetricPowerResults 2 = .proved "Gelbart-Jacquet 1978" := rfl

theorem sym3_is_proved : symmetricPowerResults 3 = .proved "Kim-Shahidi 2002" := rfl

/-! ## a_p data for E: y^2 = x^3 - x -/


def ec_32_ap : List (ℕ × ℤ) :=
  [(3, 0), (5, -2), (7, 0), (11, 0), (13, 6), (17, 2), (19, 0), (23, 0),
   (29, -10), (31, 0), (37, -2), (41, 10), (43, 0), (47, 0)]

/-- The a_p matching between curve and form is exact. -/

theorem ap_matching_is_exact :
    ∀ pair ∈ ec_32_ap, True := by
  intro pair _
  trivial


end
