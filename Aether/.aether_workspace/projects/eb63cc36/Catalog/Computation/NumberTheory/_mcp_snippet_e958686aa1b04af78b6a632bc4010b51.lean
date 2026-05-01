import Mathlib

def findWitnessFast (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  if fn ≤ 1 then 0
  else
    let divs := (List.range n).filter (fun d => 0 < d ∧ n % d = 0)
    let rem := Id.run do
      let mut rem := fn
      for _ in List.range 100 do
        let mut changed := false
        for d in divs do
          let g := Nat.gcd rem (Nat.fib d)
          if g > 1 then
            rem := rem / g
            changed := true
        if !changed then break
      return rem
    if rem ≤ 1 then 0
    else
      Id.run do
        let mut p := 2
        while p * p ≤ rem do
          if rem % p = 0 then return p
          p := p + 1
        return rem

-- Check smaller range
#eval (List.range 200).filter (fun n => n ≥ 100 ∧ ¬Nat.Prime n ∧ findWitnessFast n == 0)