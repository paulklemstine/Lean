Create a single self-contained Lean 4 file at `Catalog/Logic/FibonacciStrongDivisibility.lean` that formalizes the strong divisibility property of Fibonacci numbers and nothing unrelated.

Primary goal:
- Prove a theorem of the form
  `theorem fib_gcd (m n : ℕ) : Nat.gcd (fib m) (fib n) = fib (Nat.gcd m n)`
  or, if required by the proof route or existing library lemmas,
  `theorem fib_gcd_of_pos {m n : ℕ} (hm : 0 < m) (hn : 0 < n) : Nat.gcd (fib m) (fib n) = fib (Nat.gcd m n)`.
- If you first prove the positive-index version, also try to derive the unrestricted version by checking the zero cases.

Hard constraints:
- Stay completely on-topic: no graph theory, topology, unrelated experiments, or new speculative definitions.
- The file must typecheck without `sorry`.
- Prefer existing mathlib lemmas about Fibonacci numbers, gcd, divisibility, and Euclidean recursion whenever available.
- Keep the development compact and readable.

Recommended proof plan:
1. Inspect mathlib for existing lemmas about `fib`, especially addition formulas, divisibility, and gcd properties.
2. Prove or reuse the divisibility step:
   `m ∣ n → fib m ∣ fib n`.
   A standard route is to write `n = k*m` and prove by induction on `k` using a Fibonacci addition identity.
3. Prove a gcd-invariance step compatible with Euclid, for example:
   `Nat.gcd (fib m) (fib (m + n)) = Nat.gcd (fib m) (fib n)`
   or an equivalent modulo/subtraction recurrence.
   This should come from showing any common divisor of `fib m` and `fib n` also divides `fib (m+n)`, and conversely.
4. Use the Euclidean algorithm on indices to prove the main theorem.
   The final structure should mirror the standard proof of strong divisibility sequences.
5. If library support is strong enough, simplify aggressively and just formalize the clean final theorem with minimal auxiliary lemmas.

Desired theorem names (flexible if clashes occur):
- `fib_dvd_of_dvd`
- `fib_gcd_step`
- `fib_gcd_of_pos`
- `fib_gcd`

Implementation guidance:
- Import only what is necessary from Mathlib.
- Use `#check`-driven discovery of existing Fibonacci lemmas before reproving identities.
- If the exact theorem already exists in mathlib, then the task is to expose it cleanly in this catalog file with a short proof and any needed wrappers.
- Include brief module docstrings explaining the theorem and proof structure.

Deliverable:
- One complete Lean file `Catalog/Logic/FibonacciStrongDivisibility.lean` proving the strong divisibility theorem for Fibonacci numbers.