import Mathlib

/-! # CatalogBuild.Speculative.Other.Experiments2

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 4
-/

/-- [Section: # CatalogBuild.Speculative.Other.Experiments2
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 4] -/
def fib : ℕ → ℕ
  | 0 => 0
  | 1 => 1
  | n + 2 => fib (n + 1) + fib n

#eval Id.run do
  let mut results : Array String := #[]
  for k in List.range 15 do
    let n := fib (k + 2)  -- start from fib(2) = 1
    if n > 0 then
      let s := signature n
      results := results.push s!"fib({k+2})={n}: r₂={s.ch2}, r₄={s.ch3}"
  return results

/-- [Section: # CatalogBuild.Speculative.Other.Experiments2
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 4] -/
def ilog2 (n : ℕ) : ℕ :=
  if n ≤ 1 then 0
  else 1 + ilog2 (n / 2)

#eval Id.run do
  let N := 200
  let mut sum_log_r2 := 0
  let mut sum_log_r4 := 0
  let mut sum_log_r8 := 0
  let mut count_r2 := 0
  for n in List.range N do
    let s := signature (n + 1)
    if s.ch2 != 0 then
      sum_log_r2 := sum_log_r2 + ilog2 s.ch2.natAbs
      count_r2 := count_r2 + 1
    sum_log_r4 := sum_log_r4 + ilog2 s.ch3.natAbs
    sum_log_r8 := sum_log_r8 + ilog2 s.ch4.natAbs
  let avg_r2 : ℚ := if count_r2 = 0 then 0 else (sum_log_r2 : ℚ) / count_r2
  let avg_r4 : ℚ := (sum_log_r4 : ℚ) / N
  let avg_r8 : ℚ := (sum_log_r8 : ℚ) / N
  return s!"N={N}: avg_log2(r₂|visible)={avg_r2}, avg_log2(r₄)={avg_r4}, avg_log2(r₈)={avg_r8}, r₂_visible={count_r2}/{N}"

def isPrime (n : ℕ) : Bool :=
  if n < 2 then false
  else Id.run do
    let mut result := true
    for d in List.range (n - 2) do
      let d' := d + 2
      if d' * d' > n then return result
      if n % d' == 0 then result := false
    return result

-- Check if n has a prime factor ≡ 3 (mod 4) to an odd power

def hasBadFactor (n : ℕ) : Bool :=
  if n == 0 then true
  else Id.run do
    let mut m := n
    for p in List.range (n - 2) do
      let p' := p + 2
      if p' * p' > m then
        -- m is either 1 or a prime
        if m > 1 && m % 4 == 3 then return true
        return false
      if isPrime p' && p' % 4 == 3 then
        let mut count := 0
        while m % p' == 0 do
          m := m / p'
          count := count + 1
        if count % 2 == 1 then return true
    if m > 1 && m % 4 == 3 then return true
    return false

#eval Id.run do
  let mut mismatches := 0
  let mut total := 0
  for n in List.range 200 do
    let n' := n + 1
    let s := signature n'
    let dark := s.ch2 == 0
    let predicted_dark := hasBadFactor n'
    if dark != predicted_dark then
      mismatches := mismatches + 1
    total := total + 1
  return s!"Mismatches between r₂=0 and bad-factor prediction: {mismatches}/{total}"