Create a single clean file `FibonacciEntryPoint.lean` importing only `Mathlib.Data.Nat.Fib.Basic` and `Mathlib.Data.Nat.MinMax`. Define `fibEntry` using `Nat.find` on the predicate `fun k ↦ 0 < k ∧ m ∣ Nat.fib k`. Then prove exactly these three theorems in order, each with a COMPLETE proof (no `sorry`):

1. `theorem fibEntry_spec (m : ℕ) (h : ∃ k, 0 < k ∧ m ∣ Nat.fib k) : m ∣ Nat.fib (fibEntry m) ∧ 0 < fibEntry m` — use `Nat.find_spec`

2. `theorem fibEntry_min (m k : ℕ) (hk : 0 < k) (hmk : m ∣ Nat.fib k) : fibEntry m ∣ k` — the key step: let `d = gcd k (fibEntry m)`, then `m ∣ Nat.fib k` and `m ∣ Nat.fib (fibEntry m)` imply `m ∣ gcd (Nat.fib k) (Nat.fib (fibEntry m))`, which equals `Nat.fib (gcd k (fibEntry m)) = Nat.fib d` by `Nat.fib_gcd`. Since `d ∣ fibEntry m` and `d > 0` (because both `k` and `fibEntry m` are positive), minimality of `fibEntry m` forces `fibEntry m ≤ d`, hence `fibEntry m = d` and `d ∣ k`.

3. `theorem fibEntry_dvd_of_dvd (m n : ℕ) (hm : 0 < m) (hmn : m ∣ n) : fibEntry m ∣ fibEntry n` — apply (2) with `k := fibEntry n`, using the fact that `m ∣ n` and `n ∣ Nat.fib (fibEntry n)` imply `m ∣ Nat.fib (fibEntry n)`. Need `0 < fibEntry n` which follows from existence of `fibEntry n` (since `n ∣ Nat.fib n` when `n > 0`, which needs `n ∣ Nat.fib n` — actually just use `n ∣ Nat.fib 0 = 0` when needed, or the existence hypothesis).

CRITICAL: Every proof must be complete. If a sub-lemma is needed, state and prove it first. Do NOT include any unrelated content (no EulerianTrail, no graph theory). The file must compile without errors.