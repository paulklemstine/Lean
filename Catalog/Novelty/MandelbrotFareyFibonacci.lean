import Mathlib

/-!
# Farey Mediants, Fibonacci, and the Bulb Ordering of the Mandelbrot Set

Along the boundary of the main cardioid of the Mandelbrot set, the periods of the attached bulbs
are organised by the **Farey/Stern–Brocot** structure of their external angles `p/q`: two bulbs
`p/q` and `p'/q'` are *adjacent* exactly when `|p q' - p' q| = 1` (the unimodular / Farey-neighbour
condition), and the bulb sitting between them carries the **mediant** angle
`(p + p')/(q + q')`.

The distinguished "golden" path — following the largest satellite bulb at each stage — realises the
**Fibonacci sequence** as iterated mediants:
`1/1, 1/2, 2/3, 3/5, 5/8, …` are the ratios `F n / F (n+1)`.

This file proves:

* `fib_mediant`: the mediant of the consecutive Fibonacci ratios `F n / F (n+1)` and
  `F (n+1) / F (n+2)` is the next one, `F (n+2) / F (n+3)`;
* `fib_cassini`: Cassini's identity `F(n+1)² - F n · F(n+2) = (-1)ⁿ`, i.e. consecutive Fibonacci
  ratios are **Farey neighbours** (unimodular);
* `fib_farey_neighbor`: the resulting `|·| = 1` unimodularity statement;
* `fib_coprime`: consecutive Fibonacci numbers are coprime, so the ratios are in lowest terms.
-/

namespace FareyFibonacci

/-- The mediant of two fractions given as `(numerator, denominator)` pairs. -/
def mediant (a b : ℕ × ℕ) : ℕ × ℕ := (a.1 + b.1, a.2 + b.2)

/-
**Fibonacci as iterated mediants.**  The mediant of the consecutive Fibonacci ratios
`F n / F (n+1)` and `F (n+1) / F (n+2)` is the next Fibonacci ratio `F (n+2) / F (n+3)`.
-/
theorem fib_mediant (n : ℕ) :
    mediant (Nat.fib n, Nat.fib (n + 1)) (Nat.fib (n + 1), Nat.fib (n + 2))
      = (Nat.fib (n + 2), Nat.fib (n + 3)) := by
  simp +arith +decide [ mediant, Nat.fib_add_two ]

/-
**Cassini's identity.**  `F(n+1)² - F n · F(n+2) = (-1)ⁿ`.
-/
theorem fib_cassini (n : ℕ) :
    ((Nat.fib (n + 1) : ℤ)) ^ 2 - (Nat.fib n : ℤ) * (Nat.fib (n + 2) : ℤ) = (-1) ^ n := by
  exact Nat.recOn n ( by norm_num ) fun n ih => by norm_num [ pow_succ', Nat.fib_add_two ] at * ; linarith;

/-
**Farey-neighbour / unimodularity.**  Consecutive Fibonacci ratios `F n / F(n+1)` and
`F(n+1) / F(n+2)` are Farey neighbours: the determinant has absolute value `1`.
-/
theorem fib_farey_neighbor (n : ℕ) :
    |(Nat.fib (n + 1) : ℤ) * (Nat.fib (n + 1) : ℤ)
        - (Nat.fib n : ℤ) * (Nat.fib (n + 2) : ℤ)| = 1 := by
  -- Apply the absolute value to both sides of the equation from fib_cassini and simplify it to 1.
  have h_abs : |((Nat.fib (n + 1) : ℤ))^2 - (Nat.fib n : ℤ) * (Nat.fib (n + 2) : ℤ)| = |(-1 : ℤ)^n| := by
    exact congr_arg _ ( fib_cassini n );
  simpa [ ← sq ] using h_abs.trans ( by simp +decide )

/-
Consecutive Fibonacci numbers are coprime, so each mediant ratio `F n / F(n+1)` is already in
lowest terms.
-/
theorem fib_coprime (n : ℕ) : Nat.Coprime (Nat.fib n) (Nat.fib (n + 1)) := by
  exact Nat.recOn n ( by decide ) fun n ih => by simp_all +decide [ Nat.fib_add_two, Nat.Coprime, Nat.gcd_comm ] ;

/-
The denominators of the golden path strictly increase (`F (n+1) < F (n+2)` for `n ≥ 1`), so the
bulbs it visits shrink — the size of the `p/q` bulb decreases with `q`.
-/
theorem fib_denominator_strictMono {n : ℕ} (hn : 1 ≤ n) :
    Nat.fib (n + 1) < Nat.fib (n + 2) := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ]

end FareyFibonacci