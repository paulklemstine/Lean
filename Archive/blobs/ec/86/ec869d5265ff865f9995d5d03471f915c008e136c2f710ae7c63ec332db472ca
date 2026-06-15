## Task: Density in the Proof-Complexity Size System Preorder

Create a **single, self-contained, clean** Lean 4 file at `Logic/ProofComplexity/LadderDensity.lean`.

### Step 1: Define the Simulation Preorder

A **size system** is a function `S : ℕ → ℕ`.

Define the simulation preorder:
```
def Simulates (S T : ℕ → ℕ) : Prop :=
  ∃ d : ℕ, ∃ c : ℕ, ∃ N : ℕ, ∀ n ≥ N, S n ≤ (c + T n) ^ d
```
This captures `S(n) ≤ p(T(n))` for a polynomial `p(x) = (c + x)^d`.

Define strict simulation: `S ≺ T := Simulates S T ∧ ¬Simulates T S`

### Step 2: Define the Power Ladder

```
def powSystem (k : ℕ) (n : ℕ) : ℕ := 2 ^ (n ^ k)
```

### Step 3: Prove the Ladder is Strict

**Theorem `powSystem_lt_powSystem`**: For all `k ≥ 1`, `powSystem k ≺ powSystem (k + 1)`.

Proof of `Simulates (powSystem k) (powSystem (k+1))`:
- Use `d := 1, c := 0, N := 1`.
- Show `2 ^ (n ^ k) ≤ (0 + 2 ^ (n ^ (k + 1))) ^ 1 = 2 ^ (n ^ (k + 1))`.
- This follows from `n ^ k ≤ n ^ (k + 1)` for `n ≥ 1`.
- **Prove `n ^ k ≤ n ^ (k + 1)` by induction on `k` or direct monotonicity**, not by `decide`.

Proof of `¬Simulates (powSystem (k+1)) (powSystem k)`:
- By contradiction. Assume `∃ d c N, ∀ n ≥ N, 2 ^ (n ^ (k + 1)) ≤ (c + 2 ^ (n ^ k)) ^ d`.
- Then `2 ^ (n ^ (k + 1)) ≤ (c + 2 ^ (n ^ k)) ^ d ≤ (2 ^ (n ^ k + ⌈log₂ c⌉)) ^ d = 2 ^ (d * (n ^ k + ⌈log₂ c⌉))` for large `n`.
- So `n ^ (k + 1) ≤ d * (n ^ k + ⌈log₂ c⌉) ≤ d * n ^ k + d * ⌈log₂ c⌉`.
- But `n ^ (k + 1) = n * n ^ k > d * n ^ k` for `n > d`, giving a contradiction for `n > max d N`.
- **Construct this contradiction explicitly** using `Nat.pow_succ` and arithmetic, NOT `decide`.

### Step 4: Define the Intermediate System

```
def interPowSys (k : ℕ) (n : ℕ) : ℕ :=
  if n = 0 then 1 else 2 ^ (n ^ k * (Nat.sqrt n))
```

Here `Nat.sqrt n` is the integer square root (available in Mathlib).

Key growth property: `n ^ k * Nat.sqrt n` is between `n ^ k` and `n ^ (k + 1)` for `n ≥ 1`, since:
- `n ^ k * 1 ≤ n ^ k * Nat.sqrt n` (because `Nat.sqrt n ≥ 1` for `n ≥ 1`)
- `n ^ k * Nat.sqrt n ≤ n ^ k * n = n ^ (k + 1)` (because `Nat.sqrt n ≤ n`)

But also `n ^ k * Nat.sqrt n` grows faster than `n ^ k + c` for any constant `c`, since `Nat.sqrt n → ∞`.

### Step 5: Prove Intermediate Status

**Theorem `powSystem_lt_interPowSys`**: For `k ≥ 1`, `powSystem k ≺ interPowSys k`.

- `Simulates (powSystem k) (interPowSys k)`: Use `d := 1, c := 0`. Show `2 ^ (n ^ k) ≤ 2 ^ (n ^ k * Nat.sqrt n)` since `1 ≤ Nat.sqrt n` for `n ≥ 1`.
- `¬Simulates (interPowSys k) (powSystem k)`: By contradiction. If `2 ^ (n ^ k * Nat.sqrt n) ≤ (c + 2 ^ (n ^ k)) ^ d`, then `n ^ k * Nat.sqrt n ≤ d * (n ^ k + ⌈log₂ c⌉)`. But `Nat.sqrt n ≥ n / 2` for `n ≥ 4` (actually `Nat.sqrt n ≥ √(n/2)` ... need a cleaner bound). Better: `Nat.sqrt n ≥ n^(1/3)` for `n ≥ 1` (since `n^(2/3) ≤ n` for `n ≥ 1`... hmm, `(n^(1/3))^2 = n^(2/3) ≤ n` for `n ≥ 1`, so `Nat.sqrt n ≥ n^(1/3)`... not exactly, `Nat.sqrt n = ⌊√n⌋ ≥ √n - 1`). Use the bound `Nat.sqrt n ≥ n / (Nat.sqrt n + 1) ≥ n / (2 * √n) = √n / 2` for `n ≥ 4`. Actually, the cleanest: for `n ≥ 4`, `Nat.sqrt n ≥ 2`, so `n ^ k * Nat.sqrt n ≥ 2 * n ^ k`. And `d * (n ^ k + c') < 2 * n ^ k` for large `n` when `d < 2`. But for `d ≥ 2`... Hmm.

Let me use a cleaner intermediate system that avoids square roots entirely:

```
def interPowSys (k : ℕ) (n : ℕ) : ℕ := 2 ^ (n ^ k * n)
```

Wait, that's `2 ^ (n ^ (k+1)) = powSystem (k+1) n`. Not intermediate!

How about: `interPowSys k n := 2 ^ (n ^ k + n ^ k * n)` = `2 ^ (n ^ k * (1 + n))` = `2 ^ (n ^ k + n ^ (k+1))`. Since `n ^ k + n ^ (k+1) = n ^ k * (1 + n)`, and `n ^ (k+1) ≤ n ^ k * (1 + n) ≤ 2 * n ^ (k+1)` for `n ≥ 1`, this system is simulation-equivalent to `powSystem (k+1)` (since `2 ^ (n ^ (k+1)) ≤ 2 ^ (n ^ k * (1 + n)) ≤ 2 ^ (2 * n ^ (k+1)) = (2 ^ (n ^ (k+1))) ^ 2`).

So this doesn't work either.

**The fundamental issue**: In the simulation preorder with polynomial bounds on the SIZE values (not on the input), two systems that differ by a polynomial factor in the exponent are equivalent. `2 ^ (c * n ^ k)` is simulation-equivalent to `2 ^ (n ^ k)` for any constant `c > 0`. So we need the exponent to grow STRICTLY between `n ^ k` and `n ^ (k+1)` in a way that polynomial composition can't bridge.

The exponent `n ^ k * Nat.sqrt n = n ^ (k + 1/2)` does work because:
- `2 ^ (n ^ (k + 1/2))` is NOT polynomially bounded by `2 ^ (n ^ k)` (since `n ^ (k+1/2) / (n ^ k + c) → ∞`)
- `2 ^ (n ^ (k + 1/2))` IS polynomially bounded by `2 ^ (n ^ (k+1))` (since `n ^ (k+1/2) ≤ n ^ (k+1)`, so `2 ^ (n ^ (k+1/2)) ≤ 2 ^ (n ^ (k+1)) ≤ (2 ^ (n ^ (k+1))) ^ 1`)
- `2 ^ (n ^ k)` IS polynomially bounded by `2 ^ (n ^ (k+1/2))` (since `n ^ k ≤ n ^ (k+1/2)`, so `2 ^ (n ^ k) ≤ 2 ^ (n ^ (k+1/2))`)
- `2 ^ (n ^ (k+1))` is NOT polynomially bounded by `2 ^ (n ^ (k+1/2))` (since `n ^ (k+1) / (n ^ (k+1/2) + c) → ∞`, so `2 ^ (n ^ (k+1)) / (2 ^ (n ^ (k+1/2))) ^ d → ∞` for any `d`)

So `interPowSys k n := 2 ^ (n ^ k * Nat.sqrt n)` IS strictly intermediate. The proof of `¬Simulates (interPowSys k) (powSystem k)` goes:
- Assume `2 ^ (n ^ k * Nat.sqrt n) ≤ (c + 2 ^ (n ^ k)) ^ d` for all `n ≥ N`.
- Then `n ^ k * Nat.sqrt n ≤ d * (n ^ k + ⌈log₂ c⌉)` (roughly, after taking logs).
- More carefully: `(c + 2 ^ (n ^ k)) ^ d ≤ (2 * 2 ^ (n ^ k)) ^ d = 2 ^ (d * (n ^ k + 1))` for large `n` (when `c ≤ 2 ^ (n ^ k)`).
- So `2 ^ (n ^ k * Nat.sqrt n) ≤ 2 ^ (d * (n ^ k + 1))`, giving `n ^ k * Nat.sqrt n ≤ d * (n ^ k + 1) = d * n ^ k + d`.
- But `Nat.sqrt n ≥ n / 2` for... no, `Nat.sqrt n ≤ √n`. We need `n ^ k * Nat.sqrt n > d * n ^ k + d` for large `n`.
- `n ^ k * Nat.sqrt n ≥ n ^ k * (√n - 1) ≥ n ^ k * √n / 2` for `n ≥ 4`.
- And `d * n ^ k + d ≤ 2 * d * n ^ k` for `n ≥ 1`.
- So need `n ^ k * √n / 2 > 2 * d * n ^ k`, i.e., `√n > 4 * d`, i.e., `n > 16 * d ^ 2`.
- So for `n ≥ max N (16 * d ^ 2 + 1)`, we get a contradiction.

**IMPORTANT**: Use `Nat.sqrt` from Mathlib and the bound `Nat.sqrt n ≥ √n - 1 ≥ √n / 2` for `n ≥ 4`. Prove this bound explicitly.

Similarly, `¬Simulates (powSystem (k+1)) (interPowSys k)`:
- Assume `2 ^ (n ^ (k+1)) ≤ (c + 2 ^ (n ^ k * Nat.sqrt n)) ^ d` for all `n ≥ N`.
- Then `n ^ (k+1) ≤ d * (n ^ k * Nat.sqrt n + ⌈log₂ c⌉)`.
- Since `Nat.sqrt n ≤ n`, we get `n ^ (k+1) ≤ d * (n ^ (k+1) + c')`.
- This gives `n ^ (k+1) * (1 - d) ≤ d * c'`... wait, `d * n ^ (k+1) ≥ n ^ (k+1)` when `d ≥ 1`.
- Hmm, `(c + 2 ^ (n ^ k * Nat.sqrt n)) ^ d ≥ 2 ^ (d * n ^ k * Nat.sqrt n)` for large `n` (when `c ≤ 2 ^ (n ^ k * Nat.sqrt n)`).
- So `2 ^ (n ^ (k+1)) ≤ 2 ^ (d * n ^ k * Nat.sqrt n)`, giving `n ^ (k+1) ≤ d * n ^ k * Nat.sqrt n`.
- Since `Nat.sqrt n ≤ n`, `d * n ^ k * Nat.sqrt n ≤ d * n ^ (k+1)`.
- So `n ^ (k+1) ≤ d * n ^ (k+1)`, which holds for `d ≥ 1`. No contradiction!

The issue is that `Nat.sqrt n` can be as large as `n`, making `2 ^ (n ^ k * Nat.sqrt n)` as large as `2 ^ (n ^ (k+1))`. So `(c + 2 ^ (n ^ k * Nat.sqrt n)) ^ d` CAN dominate `2 ^ (n ^ (k+1))` with `d = 1`.

Wait, let's re-examine. `Simulates (powSystem (k+1)) (interPowSys k)` means: `powSystem (k+1) n ≤ p(interPowSys k n)` for some polynomial `p`. That is, `2 ^ (n ^ (k+1)) ≤ p(2 ^ (n ^ k * Nat.sqrt n))`.

With `p(x) = x^d`, we need `2 ^ (n ^ (k+1)) ≤ 2 ^ (d * n ^ k * Nat.sqrt n)`, i.e., `n ^ (k+1) ≤ d * n ^ k * Nat.sqrt n`, i.e., `n ≤ d * Nat.sqrt n`, i.e., `√n ≤ d`. This FAILS for `n > d²`.

With a general polynomial `p(x) = a_d * x^d + ... + a_0`, for large `x`, `p(x) ≤ C * x^d` for some `C`. So `p(2 ^ (n ^ k * Nat.sqrt n)) ≤ C * 2 ^ (d * n ^ k * Nat.sqrt n)`. We need `2 ^ (n ^ (k+1)) ≤ C * 2 ^ (d * n ^ k * Nat.sqrt n)`, i.e., `n ^ (k+1) ≤ d * n ^ k * Nat.sqrt n + log₂(C)`, i.e., `n ≤ d * Nat.sqrt n + log₂(C) / n ^ k`, i.e., `√n ≤ d + (log₂(C) / n ^ k) / √n`. For large `n`, `√n > d`, giving a contradiction.

So `¬Simulates (powSystem (k+1)) (interPowSys k)` DOES hold, but the proof requires showing that `√n > d` for large `n`, which is straightforward.

Great, so the system `interPowSys k n := 2 ^ (n ^ k * Nat.sqrt n)` IS strictly intermediate between `powSystem k` and `powSystem (k+1)`.

### Summary of Required Theorems

1. `Simulates (powSystem k) (interPowSys k)` — with `d := 1, c := 0`
2. `¬Simulates (interPowSys k) (powSystem k)` — by contradiction using `Nat.sqrt n → ∞`
3. `Simulates (interPowSys k) (powSystem (k+1))` — with `d := 1, c := 0` (since `n ^ k * Nat.sqrt n ≤ n ^ (k+1)`)
4. `¬Simulates (powSystem (k+1)) (interPowSys k)` — by contradiction using `√n → ∞`
5. `powSystem_lt_powSystem : powSystem k ≺ powSystem (k+1)` — as a corollary of (1-4) plus transitivity or direct proof
6. `interPowSys_strictly_between : powSystem k ≺ interPowSys k ∧ interPowSys k ≺ powSystem (k+1)`

### CRITICAL Requirements

1. **NO `sorry`** — every theorem must be fully proved.
2. **NO `decide` or `simp_all +decide`** for asymptotic statements. Use explicit arithmetic and induction.
3. **Clean file** — no content from unrelated projects.
4. **Use `Nat.sqrt`** from Mathlib for the intermediate system.
5. **Prove key bounds explicitly**: `Nat.sqrt n ≥ 1` for `n ≥ 1`, `Nat.sqrt n ≤ n` for all `n`, `n ^ k * Nat.sqrt n ≤ n ^ (k+1)` for `n ≥ 1` and `k ≥ 1`.
6. **For the non-simulation proofs**, derive explicit contradictions by choosing `n` large enough relative to the polynomial degree `d` and constant `c`.