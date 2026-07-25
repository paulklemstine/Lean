import Mathlib

-- Alternative: use a faster checker that computes a witness
-- and then verify the witness is correct

-- Key insight: for a fixed witness (n, p), checking the three conditions
-- is MUCH faster than factoring fib n

-- Let me define a function that returns a witness p for each n
def findWitness (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  let divs := (List.range n).filter (fun d => 0 < d ∧ n % d = 0)
  Id.run do
    let mut rem := fn
    let mut p := 2
    while p * p ≤ rem do
      if rem % p = 0 then
        if divs.all (fun d => Nat.fib d % p != 0) then
          return p
        while rem % p = 0 do rem := rem / p
      p := p + 1
    if rem > 1 then
      if divs.all (fun d => Nat.fib d % rem != 0) then
        return rem
    return 0  -- no witness found

-- A check using the witness: much faster
def checkWithWitness (n p : ℕ) : Bool :=
  (p ≥ 2) &&
  (Nat.fib n % p == 0) &&
  -- check p is prime (trial division up to sqrt p)
  (Id.run do
    let mut d := 2
    while d * d ≤ p do
      if p % d == 0 then return false
      d := d + 1
    return true) &&
  -- check p doesn't divide F(d) for proper divisors d | n
  ((List.range n).filter (fun d => 0 < d ∧ n % d = 0)).all
    (fun d => Nat.fib d % p != 0)

-- Pre-compute witnesses
#eval (List.range 300).filter (fun n => n ≥ 13 ∧ ¬Nat.Prime n) |>.map (fun n => (n, findWitness n)) |>.filter (fun (_, p) => p == 0)