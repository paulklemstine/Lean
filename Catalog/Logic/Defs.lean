
/-! # CatalogBuild.Logic.Defs

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 8
-/

/-- r₂(n): number of representations of n as a sum of 2 squares (with signs and order).
Formula: r₂(n) = 4 · Σ_{d|n} χ₋₄(d). -/
def r2 (n : ℕ) : ℤ :=
  4 * ∑ d ∈ (Nat.divisors n), chi4 (d : ℤ)

/-- r₄(n): number of representations of n as a sum of 4 squares.
Jacobi's four-square theorem: r₄(n) = 8 · Σ_{d|n, 4∤d} d. -/
def r4 (n : ℕ) : ℤ :=
  8 * ∑ d ∈ (Nat.divisors n).filter (fun d => ¬(4 ∣ d)), (d : ℤ)

/-- r₈(n): number of representations of n as a sum of 8 squares.
Formula: r₈(n) = 16 · Σ_{d|n} (-1)^{n+d} · d³. -/
def r8 (n : ℕ) : ℤ :=
  16 * ∑ d ∈ (Nat.divisors n), ((-1 : ℤ) ^ (n + d) * (d : ℤ) ^ 3)

/-- The four-channel signature of a positive integer. -/
structure IntSignature where
  ch1 : ℤ  -- Channel 1: trivially 1 for all n ≥ 1 (every n is a sum of 1 square... of itself, but we use r₁(n) = 2 if n is a perfect square, 0 otherwise, or just n itself)
  ch2 : ℤ  -- Channel 2: r₂(n)
  ch3 : ℤ  -- Channel 3: r₄(n)
  ch4 : ℤ  -- Channel 4: r₈(n)
  deriving Repr

/-- Compute the four-channel signature of n. -/
def signature (n : ℕ) : IntSignature where
  ch1 := n
  ch2 := r2 n
  ch3 := r4 n
  ch4 := r8 n

/-- Squared Euclidean distance between two signatures (using integer arithmetic). -/
def sigDistSq (s t : IntSignature) : ℤ :=
  (s.ch1 - t.ch1)^2 + (s.ch2 - t.ch2)^2 + (s.ch3 - t.ch3)^2 + (s.ch4 - t.ch4)^2

/-- Normalized signature: each channel divided by n (as rationals). -/
structure NormSignature where
  ch1 : ℚ
  ch2 : ℚ
  ch3 : ℚ
  ch4 : ℚ
  deriving Repr

/-- Compute the normalized signature. -/
def normSignature (n : ℕ) (hn : n ≠ 0) : NormSignature :=
  let s := signature n
  { ch1 := (s.ch1 : ℚ) / n
    ch2 := (s.ch2 : ℚ) / n
    ch3 := (s.ch3 : ℚ) / n
    ch4 := (s.ch4 : ℚ) / n }
