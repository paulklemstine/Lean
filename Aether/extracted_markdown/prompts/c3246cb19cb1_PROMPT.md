Create one self-contained Lean 4 file formalizing the exact row-complexity theorem for Rule 90 via parity of binomial coefficients, with a deliberately conservative proof strategy that minimizes dependence on unformalized folklore.

Precise task:
1. Define
   `complexity (t : ℕ) : ℕ := ((Finset.range (t+1)).filter (fun k => Nat.Odd (Nat.choose t k))).card`.
   Equivalently, any definition over `k ≤ t` is fine if it is easy to reason about.
2. Prove the two structural recurrences
   - `complexity (2*n) = complexity n`
   - `complexity (2*n+1) = 2 * complexity n`
   using a clean partition of `k < 2*n+1` or `k < 2*n+2` into even/odd indices.
3. For the parity facts, do not attempt a broad Lucas theorem unless Mathlib already provides exactly what you need. Instead, prove only the specific mod-2 lemmas needed for the recurrence. Acceptable routes include:
   - using known identities for central/even/odd binomial coefficients and parity-preservation under doubling,
   - or proving the specialized parity recursion for `Nat.choose` at base 2.
   The goal is a finished proof artifact, not maximal generality.
4. Introduce a bit-count function on `ℕ` if needed, or reuse an existing one if available in Mathlib. Prove the corresponding recurrences
   - `popcount (2*n) = popcount n`
   - `popcount (2*n+1) = popcount n + 1`.
5. Deduce by binary recursion / strong induction the main theorem
   `complexity t = 2 ^ popcount t`.
6. Derive explicit corollaries:
   - `complexity (2^k) = 2` (preferably for `k ≥ 1`, with `k=0` handled separately if needed),
   - `complexity (2^k - 1) = 2^k`.
7. Keep the file tightly focused. Remove all unrelated material. No cryptographic prose beyond a brief introductory sentence that Rule 90 rows are Pascal rows mod 2.

Requirements:
- The file must compile without `sorry`.
- Prefer short, robust theorem statements over ambitious abstractions.
- If a theorem is awkward for `k=0`, split into two lemmas rather than forcing a brittle statement.
- Use `Catalog/FINAL/` results if they genuinely help, but do not depend on speculative in-progress files.
- Include a concise module docstring explaining the exact theorem and the two infinite subsequences.

Suggested proof architecture:
- First prove helper lemmas about mapping `r ↦ 2*r` and `r ↦ 2*r+1` over ranges.
- Then prove parity classification lemmas for `Nat.choose (2*n) k` and `Nat.choose (2*n+1) k` based on parity of `k`.
- Translate those into card equalities for filtered finsets.
- Separately prove the analogous binary recurrences for popcount.
- Finish with induction on `t` using `Nat.binaryRec`-style reasoning or parity splitting into even/odd cases.

If Mathlib lacks a convenient `popcount`, define your own recursive `bitcount : ℕ → ℕ` by parity splitting and use that in the main theorem; the mathematical target is the exact formula, not adherence to a particular identifier.