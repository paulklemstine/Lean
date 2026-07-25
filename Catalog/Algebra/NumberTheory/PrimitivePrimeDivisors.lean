import Mathlib

def getDivisors (n : ℕ) : List ℕ :=
  (List.range n).filter (fun d => d > 0 ∧ n % d = 0)

def findPrimitivePrime (n : ℕ) : Option ℕ := do
  let fn := Nat.fib n
  if fn ≤ 1 then none
  else
    let divs := getDivisors n
    let mut remaining := fn
    let mut p := 2
    while p * p ≤ remaining do
      if remaining % p = 0 then
        let primitive := !divs.any (fun d => Nat.fib d % p == 0)
        if primitive then return p
        while remaining % p = 0 do remaining := remaining / p
      p := p + 1
    if remaining > 1 then
      let primitive := !divs.any (fun d => Nat.fib d % remaining == 0)
      if primitive then return remaining
    none

-- Check all composite n from 4 to 200
def checkRange : List (ℕ × Bool) :=
  (List.range 200).filter (fun n => n ≥ 13 ∧ ¬ Nat.Prime n) |>.map (fun n =>
    (n, (findPrimitivePrime n).isSome))

-- Check if any fails
#eval checkRange.filter (fun (_, b) => !b)