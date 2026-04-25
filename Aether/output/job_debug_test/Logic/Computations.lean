import Mathlib

/-! # CatalogBuild.Logic.Computations

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 8
-/

/-- Count divisors of n that are ≡ r (mod 4) -/
def countDivisorsMod4 (n : ℕ) (r : ℕ) : ℕ :=
  ((Nat.divisors n).filter (fun d => d % 4 = r)).card

/-- d₁(n) - d₃(n): the Channel 2 signal -/
def complexSignal (n : ℕ) : Int :=
  ↑(countDivisorsMod4 n 1) - ↑(countDivisorsMod4 n 3)

/-- Jacobi sum for Channel 3: Σ_{d|n, 4∤d} d -/
def jacobiSumC (n : ℕ) : ℕ :=
  ((Nat.divisors n).filter (fun d => d % 4 ≠ 0)).sum id

/-- Channel 4 signal: Σ_{d|n} (-1)^{n+d} d³ -/
def octonionicSignal (n : ℕ) : Int :=
  (Nat.divisors n).sum fun d =>
    if (n + d) % 2 = 0 then (↑d : Int) ^ 3 else -(↑d : Int) ^ 3

/-- Full four-channel signature as a string -/
def signatureStr (n : ℕ) : String :=
  let isSq := Nat.sqrt n ^ 2 == n
  let ch2 := complexSignal n
  let ch3 := jacobiSumC n
  let ch4 := octonionicSignal n
  s!"n={n}: sq={isSq} ch2={ch2} ch3={ch3} ch4={ch4}"

/-- Predicted r₂(n) = 4 * complexSignal(n) -/
def predicted_r₂ (n : ℕ) : Int := 4 * complexSignal n

/-- Predicted r₄(n) = 8 * jacobiSumC(n) -/
def predicted_r₄ (n : ℕ) : ℕ := 8 * jacobiSumC n

/-- Predicted r₈(n) = 16 * octonionicSignal(n) -/
def predicted_r₈ (n : ℕ) : Int := 16 * octonionicSignal n

