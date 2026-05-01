/-! # CatalogBuild.Bridges.BerggrenTropicalRankComputation

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 4
-/

import Mathlib

/-- Compute all primitive Pythagorean triples with n as a leg. -/
def primTriplesWithLeg (n : ℕ) : List (ℕ × ℕ × ℕ) := Id.run do
  let mut result : List (ℕ × ℕ × ℕ) := []
  if n % 2 == 1 then
    for d₁ in List.range n do
      let d₁ := d₁ + 1
      if n % d₁ == 0 then
        let d₂ := n / d₁
        if d₂ > d₁ && d₁ % 2 == 1 && d₂ % 2 == 1 then
          let m := (d₁ + d₂) / 2
          let kk := (d₂ - d₁) / 2
          if kk > 0 && Nat.gcd m kk == 1 then
            result := result ++ [(n, 2 * m * kk, m * m + kk * kk)]
  if n % 2 == 0 then
    let half := n / 2
    for kk in List.range half do
      let kk := kk + 1
      if half % kk == 0 then
        let m := half / kk
        if m > kk && Nat.gcd m kk == 1 && (m + kk) % 2 == 1 then
          result := result ++ [(m * m - kk * kk, n, m * m + kk * kk)]
  return result


/-- Count prime factors with multiplicity (Ω function). -/
def bigOmega (n : ℕ) : ℕ := Id.run do
  let mut count := 0
  let mut m := n
  let mut p := 2
  while p * p ≤ m do
    while m % p == 0 do
      count := count + 1
      m := m / p
    p := p + 1
  if m > 1 then count := count + 1
  return count


/-- Count distinct prime factors (ω function). -/
def littleOmega (n : ℕ) : ℕ := Id.run do
  let mut count := 0
  let mut m := n
  let mut p := 2
  while p * p ≤ m do
    if m % p == 0 then
      count := count + 1
      while m % p == 0 do
        m := m / p
    p := p + 1
  if m > 1 then count := count + 1
  return count


/-- [Section: # Computational Exploration: Berggren–Tropical Rank Conjecture
This file provides computational evidence that the conjecture
tropRank(M_n) = Ω(n) is false, by computing |S(n)| (the number of
primitive Pythagorean triples with n as a leg) and Ω(n) for small n.
Since tropRank(M_n) ≤ |S(n)| (tropical rank ≤ number of rows), any n
with |S(n)| < Ω(n) is an automatic counterexample. We also identify
cases where |S(n)| > Ω(n), showing the conjecture fails in both directions.] -/
def isSquarefree (n : ℕ) : Bool := Id.run do
  let mut m := n
  let mut p := 2
  while p * p ≤ m do
    if m % (p * p) == 0 then return false
    while m % p == 0 do m := m / p
    p := p + 1
  return true

