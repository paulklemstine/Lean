/-! # CatalogBuild.Computation.Factoring.InsideOutFactor

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 17
-/

import Mathlib

/-- Apply inverse Berggren matrix B₁⁻¹ -/
def applyInvBG1 (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  fun i => match i with
  | 0 => v 0 + 2 * v 1 - 2 * v 2
  | 1 => -2 * v 0 - v 1 + 2 * v 2
  | 2 => -2 * v 0 - 2 * v 1 + 3 * v 2


/-- Apply inverse Berggren matrix B₂⁻¹ -/
def applyInvBG2 (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  fun i => match i with
  | 0 => v 0 + 2 * v 1 - 2 * v 2
  | 1 => 2 * v 0 + v 1 - 2 * v 2
  | 2 => -2 * v 0 - 2 * v 1 + 3 * v 2


/-- Apply inverse Berggren matrix B₃⁻¹ -/
def applyInvBG3 (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  fun i => match i with
  | 0 => -v 0 - 2 * v 1 + 2 * v 2
  | 1 => 2 * v 0 + v 1 - 2 * v 2
  | 2 => -2 * v 0 - 2 * v 1 + 3 * v 2


/-- Find the parent of a Pythagorean triple in the Berggren tree.
Returns (branch, a', b', c') where branch ∈ {1,2,3} indicates
which inverse matrix was used. -/
def findBerggrenParent (a b c : ℤ) : ℕ × ℤ × ℤ × ℤ :=
  let a1 := a + 2*b - 2*c
  let b1 := -2*a - b + 2*c
  let c1 := -2*a - 2*b + 3*c
  let a2 := a + 2*b - 2*c
  let b2 := 2*a + b - 2*c
  if 0 < a1 && 0 < b1 then (1, a1, b1, c1)
  else if 0 < a2 && 0 < b2 then (2, a2, b2, c1)
  else
    let a3 := -a - 2*b + 2*c
    let b3 := 2*a + b - 2*c
    (3, a3, b3, c1)


/-- The inside-out factoring algorithm.
Given odd N, constructs the Euclid triple and descends,
checking GCDs at each step. Returns first nontrivial factor found. -/
def insideOutFactor (N : ℕ) (maxSteps : ℕ) : Option (ℕ × ℕ) := Id.run do
  if N % 2 == 0 || N < 9 then return none
  let m : ℤ := ((N : ℤ) + 1) / 2
  let n : ℤ := ((N : ℤ) - 1) / 2
  -- Construct the Euclid triple: (m²-n², 2mn, m²+n²) = (N, 2mn, m²+n²)
  let mut a : ℤ := m ^ 2 - n ^ 2  -- = N
  let mut b : ℤ := 2 * m * n
  let mut c : ℤ := m ^ 2 + n ^ 2
  for _ in List.range maxSteps do
    if a == 3 && b == 4 && c == 5 then break
    -- Check GCD of each leg with N
    let ga := Nat.gcd a.natAbs N
    let gb := Nat.gcd b.natAbs N
    if 1 < ga && ga < N then return some (ga, N / ga)
    if 1 < gb && gb < N then return some (gb, N / gb)
    -- Descend to parent
    let (_, pa, pb, pc) := findBerggrenParent a b c
    a := pa; b := pb; c := pc
  return none


/-- Extended version: returns ALL factors found during descent -/
def insideOutFactorAll (N : ℕ) (maxSteps : ℕ) : List (ℕ × ℕ × ℕ) := Id.run do
  if N % 2 == 0 || N < 9 then return []
  let m : ℤ := ((N : ℤ) + 1) / 2
  let n : ℤ := ((N : ℤ) - 1) / 2
  let mut a : ℤ := m ^ 2 - n ^ 2
  let mut b : ℤ := 2 * m * n
  let mut c : ℤ := m ^ 2 + n ^ 2
  let mut results : List (ℕ × ℕ × ℕ) := []
  for step in List.range maxSteps do
    if a == 3 && b == 4 && c == 5 then break
    let ga := Nat.gcd a.natAbs N
    let gb := Nat.gcd b.natAbs N
    if 1 < ga && ga < N then
      results := (step, ga, N / ga) :: results
    if 1 < gb && gb < N then
      results := (step, gb, N / gb) :: results
    let (_, pa, pb, pc) := findBerggrenParent a b c
    a := pa; b := pb; c := pc
  return results.reverse


/-- Find all representations of n = a² + b² with 0 < a ≤ b -/
def sumOfTwoSquaresReps (n : ℕ) : List (ℕ × ℕ) :=
  let sq := Nat.sqrt n
  (List.range (sq + 1)).filterMap fun a =>
    if a > 0 then
      let b2 := n - a * a
      let b := Nat.sqrt b2
      if b * b == b2 && a ≤ b then some (a, b)
      else none
    else none


/-- Factor N by finding non-primitive Pythagorean triples with hypotenuse N.
If N² = a² + b² and gcd(a, b, N) = d > 1, then d | N is a factor. -/
def factorViaSumOfSquares (N : ℕ) : List (ℕ × ℕ × ℕ × ℕ) :=
  let decomps := sumOfTwoSquaresReps (N * N)
  decomps.filterMap fun (a, b) =>
    let g := Nat.gcd (Nat.gcd a b) N
    if g > 1 && g < N then some (a, b, g, N / g)
    else none

-- Test: 65 = 5 × 13. Has primes ≡ 1 mod 4!
#eval factorViaSumOfSquares 65    -- reveals 5 and 13

-- Test: 85 = 5 × 17
#eval factorViaSumOfSquares 85

-- Test: 221 = 13 × 17
#eval factorViaSumOfSquares 221

-- Test: 77 = 7 × 11 (both ≡ 3 mod 4 — no non-trivial decompositions)
#eval factorViaSumOfSquares 77    -- empty! Both primes ≡ 3 mod 4


/-- Factor N by first multiplying by auxiliary prime 5 -/
def factorViaAuxiliary (N : ℕ) (aux : ℕ) : List (ℕ × ℕ) :=
  let N' := N * aux
  let decomps := sumOfTwoSquaresReps (N' * N')
  let factors := decomps.filterMap fun (a, b) =>
    let ga := Nat.gcd a N
    let gb := Nat.gcd b N
    let results : List (ℕ × ℕ) := []
    let results := if 1 < ga && ga < N then (ga, N / ga) :: results else results
    let results := if 1 < gb && gb < N then (gb, N / gb) :: results else results
    if results.isEmpty then none else some results
  factors.flatMap id

-- Factor 77 = 7 × 11 using auxiliary prime 5
#eval factorViaAuxiliary 77 5

-- Factor 77 = 7 × 11 using auxiliary prime 13
#eval factorViaAuxiliary 77 13


/-- The Euclid parametrization produces a valid Pythagorean triple -/
theorem euclid_triple_valid (N : ℤ) (hodd : N % 2 = 1) :
    let m := (N + 1) / 2
    let n := (N - 1) / 2
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring


/-- The odd leg of the Euclid triple is exactly N -/
theorem euclid_odd_leg (N : ℤ) (hodd : N % 2 = 1) :
    let m := (N + 1) / 2
    let n := (N - 1) / 2
    m ^ 2 - n ^ 2 = N := by
  simp only
  have hN : N = 2 * ((N - 1) / 2) + 1 := by omega
  have hm : (N + 1) / 2 = (N - 1) / 2 + 1 := by omega
  rw [hm]; ring_nf
  omega


/-- Inverse Berggren maps preserve the Lorentz form (algebraically) -/
theorem invB1_preserves_form (a b c : ℤ) :
    (a + 2*b - 2*c)^2 + (-2*a - b + 2*c)^2 - (-2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring


/-- [Section: # CatalogBuild.Computation.Factoring.InsideOutFactor
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 17] -/
theorem invB2_preserves_form (a b c : ℤ) :
    (a + 2*b - 2*c)^2 + (2*a + b - 2*c)^2 - (-2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring


/-- [Section: # CatalogBuild.Computation.Factoring.InsideOutFactor
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 17] -/
theorem invB3_preserves_form (a b c : ℤ) :
    (-a - 2*b + 2*c)^2 + (2*a + b - 2*c)^2 - (-2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring


/-- If gcd(a, N) = d with 1 < d < N, then d divides N (factor found) -/
theorem gcd_reveals_factor (a N d : ℕ) (hd : d = Nat.gcd a N)
    (h1 : 1 < d) (h2 : d < N) : d ∣ N := by
  rw [hd]; exact Nat.gcd_dvd_right a N


/-- The parent hypotenuse c' = -2a-2b+3c satisfies c' < c when a,b > 0 -/
theorem parent_hyp_decreases (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a^2 + b^2 = c^2) :
    -2*a - 2*b + 3*c < c := by
  nlinarith [sq_nonneg (a + b - c)]


/-- The hypotenuse decrease is exactly 2(a+b-c) -/
theorem hyp_decrease_exact (a b c : ℤ) :
    c - (-2*a - 2*b + 3*c) = 2*(a + b) - 2*c := by ring


