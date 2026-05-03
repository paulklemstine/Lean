import Mathlib
import Cryptography.BerggrenSL2.MatRed

/-!
# Injectivity of Powers of Hyperbolic SL₂(ℤ) Elements

For a matrix `g ∈ SL₂(ℤ)` with `trace g > 2` (the hyperbolic case),
we prove that the map `n ↦ g^n` is injective on `ℕ`.

## Proof strategy

We use the Cayley–Hamilton theorem for 2×2 matrices: since `det g = 1`,
the matrix satisfies `g² = (trace g) · g - 1`. This gives a recurrence
for traces of powers:

  `trace (g^(n+2)) = (trace g) · trace (g^(n+1)) - trace (g^n)`

When `trace g > 2`, this sequence is strictly increasing for `n ≥ 0`,
so distinct powers have distinct traces and hence are distinct matrices.
-/

open Matrix

/-! ## Cayley–Hamilton for 2×2 matrices with det = 1 -/

/-
For a 2×2 integer matrix with `det g = 1`, the Cayley–Hamilton relation gives
`g ^ 2 = (trace g) • g - 1`.
-/
theorem sq_eq_trace_smul_sub_one
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (hdet : g.det = 1) :
    g ^ 2 = (Matrix.trace g) • g - 1 := by
  norm_num [ sq, Matrix.mul_apply, Matrix.trace_fin_two, hdet ];
  norm_num [ mul_apply, ← Matrix.ext_iff ];
  erw [ show ( g 0 0 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => if i = 0 then g 0 0 else g 0 0 ) from by ext i j; fin_cases i <;> fin_cases j <;> rfl, show ( g 1 1 : Matrix ( Fin 2 ) ( Fin 2 ) ℤ ) = Matrix.diagonal ( fun i => if i = 0 then g 1 1 else g 1 1 ) from by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; simp +decide [ Matrix.det_fin_two ] at hdet ⊢ ; constructor <;> constructor <;> linarith!

/-
Trace recurrence: `trace (g^(n+2)) = trace g * trace (g^(n+1)) - trace (g^n)`.
This follows from the Cayley–Hamilton relation `g² = tr(g)·g - I`.
-/
theorem trace_pow_recurrence
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (hdet : g.det = 1) (n : ℕ) :
    Matrix.trace (g ^ (n + 2)) =
      Matrix.trace g * Matrix.trace (g ^ (n + 1)) - Matrix.trace (g ^ n) := by
  -- By multiplying both sides of the equation $g^2 = (Matrix.trace g) • g - 1$ by $g^n$, we get $g^{n+2} = (Matrix.trace g) • g^{n+1} - g^n$.
  have h_mul : g^(n+2) = (Matrix.trace g) • g^(n+1) - g^n := by
    -- By multiplying both sides of the equation $g^2 = (Matrix.trace g) • g - 1$ by $g^n$, we get $g^{n+2} = (Matrix.trace g) • g^{n+1} - g^n$ using the properties of matrix multiplication.
    have h_mul : g^(n+2) = (g^2) * g^n := by
      rw [ ← pow_add, add_comm ];
    rw [ h_mul, sq_eq_trace_smul_sub_one g hdet ] ; simp +decide [ mul_assoc, pow_succ' ] ;
    simp +decide [ sub_mul, mul_assoc ];
  rw [ h_mul, Matrix.trace_sub, Matrix.trace_smul ] ; norm_num

/-
The trace of `g^0 = I` is `2` (the dimension).
-/
theorem trace_pow_zero (g : Matrix (Fin 2) (Fin 2) ℤ) :
    Matrix.trace (g ^ 0) = 2 := by
  norm_num

/-
The sequence `n ↦ trace(g^n)` is strictly monotone for `n ≥ 0`
when `trace g > 2`. More precisely, `trace(g^(n+1)) > trace(g^n)` for all `n`.
-/
theorem trace_pow_strictMono
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (hdet : g.det = 1)
    (htr : 2 < Matrix.trace g) :
    StrictMono (fun n : ℕ => Matrix.trace (g ^ n)) := by
  -- We prove by induction that `t(n+1) > t(n)` and `t(n+1) ≥ 2` for all `n`.
  have h_ind : ∀ n, Matrix.trace (g ^ (n + 1)) > Matrix.trace (g ^ n) ∧ Matrix.trace (g ^ (n + 1)) ≥ 2 := by
    intro n
    induction' n with n ih;
    · norm_num +zetaDelta at *;
      exact ⟨ htr, htr.le ⟩;
    · have := trace_pow_recurrence g hdet n; norm_num at *; constructor <;> nlinarith;
  exact strictMono_nat_of_lt_succ fun n => h_ind n |>.1

/-- **Berggren power injectivity**: For a hyperbolic element `g ∈ SL₂(ℤ)`
(meaning `trace g > 2`), the map `n ↦ g^n` is injective on `ℕ`.

This is the faithfulness statement ensuring that the exponent in a
Berggren-tree generator is not accidentally collapsed. -/
theorem berggren_pow_injective
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (hdet : g.det = 1)
    (htr : 2 < Matrix.trace g) :
    Function.Injective (fun n : ℕ => g ^ n) := by
  intro m n hmn
  have htr_inj := (trace_pow_strictMono g hdet htr).injective
  exact htr_inj (congrArg Matrix.trace hmn)

/-- Equivalent biconditional form: `g^m = g^n ↔ m = n`. -/
theorem berggren_pow_eq_iff
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (hdet : g.det = 1)
    (htr : 2 < Matrix.trace g) :
    ∀ {m n : ℕ}, g ^ m = g ^ n ↔ m = n :=
  fun {m n} => ⟨fun h => berggren_pow_injective g hdet htr h, fun h => congrArg _ h⟩