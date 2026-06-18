Write exactly one Lean file at `Catalog/Bridges/PrimeIndexPrimitiveDivisors.lean` and no other files. The file must compile sorry-free and contain only a minimal import, a short module docstring, and the two theorems below inside `namespace StrongDivSeq`.

Target import:
- `import Catalog.Bridges.StrongDivisibilitySequences`

Required contents:
1. `theorem entryPoint_ne_one {p : ℕ} (h1 : ¬ p ∣ s.a 1) : s.entryPoint p ≠ 1`
2. `theorem isPrimitive_of_prime_index {p n : ℕ} (hn : Nat.Prime n) (hpn : p ∣ s.a n) (h1 : ¬ p ∣ s.a 1) : s.IsPrimitive p n`

Use the existing API from `Catalog/Bridges/StrongDivisibilitySequences.lean` exactly as the backbone of the proof. In particular, the intended route is:
- From `hn.pos` and `hpn`, build `hex : ∃ k, 0 < k ∧ p ∣ s.a k`.
- Use `s.dvd_iff_entryPoint_dvd hex n` to derive `s.entryPoint p ∣ n`.
- Use the prime-divisor dichotomy for `n` to get `s.entryPoint p = 1 ∨ s.entryPoint p = n`.
- Prove `entryPoint_ne_one` by invoking the existing primitive/entry-point API at index `1`, not by introducing new theory.
- Exclude the `1` case and deduce `s.entryPoint p = n`.
- Convert this equality into `s.IsPrimitive p n` via the existing equivalence theorem (for example `primitive_iff_entryPoint_eq`, if that is the exact name in the imported file).

Important constraints:
- Do not include Fibonacci, Lucas, Mersenne, Carmichael, or any application corollaries.
- Do not create any extra helper file, scratch file, or text fragment.
- Do not restate or reprove large general lemmas already present in the imported bridge file.
- If a theorem name differs slightly from the sketch above, inspect `Catalog/Bridges/StrongDivisibilitySequences.lean` and use the exact existing name rather than inventing a new API.
- Keep the file syntactically complete and minimal.

Deliverable quality bar:
- One file only.
- Sorry-free.
- Uses the bridge entry-point API rather than ad hoc reasoning.
- Ends with the completed proof of `isPrimitive_of_prime_index`.

If needed, prefer a short explicit `cases` split on the `= 1 ∨ = n` dichotomy rather than a more elaborate proof.