Formalize a complete, standalone Lean 4 development of the Fibonacci rank of apparition and Pisano period, staying strictly within Fibonacci divisibility and modular recurrence dynamics.

Primary goal: produce one coherent file, compiling without `sorry`, centered on the theorem chain
- `m ∣ n → fibEntry m ∣ fibEntry n`
- `fibEntry (Nat.lcm m n) = Nat.lcm (fibEntry m) (fibEntry n)`
- the return-time characterization of `fibPeriod n`
- `fibEntry n ∣ fibPeriod n`

Do not pursue tropical ultrametrics, Pythagorean triples, Gaussian integers, or any other bridge topic in this cycle.

Suggested structure:
1. Define or reuse the Fibonacci sequence, `fibEntry n` (least positive index with `n ∣ Fib k`, if this already exists in the catalog then reuse it), and `fibPeriod n` as the period of the Fibonacci state transition modulo `n`.
2. Prove the divisibility functoriality of `fibEntry`: if `m ∣ n` then `fibEntry m ∣ fibEntry n`.
3. Prove the lattice law for joins: `fibEntry (Nat.lcm m n) = Nat.lcm (fibEntry m) (fibEntry n)`. If the meet law is already available from a theorem like `fib_dvd_gcd_iff`, explicitly connect it in comments/theorem statements so the lattice picture is clear, but prioritize a fully checked lcm theorem.
4. Define the Fibonacci state evolution on pairs `(Fib t, Fib (t+1))` modulo `n`, and characterize `fibPeriod n` as the minimal positive return time of the initial state. Prove a divisibility criterion of the form `k ∣ fibPeriod n ↔` the `k`-step transition acts as identity on the initial Fibonacci state modulo `n`, or another precise already-supported equivalent if the exact iff statement in the previous attempt is too strong.
5. Deduce the bridge theorem `fibEntry n ∣ fibPeriod n` from the state-return characterization.

Methodological constraints:
- Prefer existing catalog definitions and lemmas from FINAL files when available.
- Keep the file focused; a shorter complete theorem chain is better than many disconnected declarations.
- Include theorem statements with names that clearly reflect the mathematics and can seed future work on primes `p`, e.g. `fibEntry_dvd_fibPeriod`.
- If some desired definition from the earlier attempt is awkward, switch from introducing new abstractions to proving the bridge via already existing recurrence lemmas and modular identities.
- If there is any ambiguity about positivity/minimality side conditions, make them explicit in theorem statements so the result is fully formal and robust.

Deliverable: a complete Lean file with no `sorry`, proving at least the four core items above. If one of the equivalence statements for `fibPeriod` is too ambitious, replace it by a slightly weaker but still precise divisibility characterization that is sufficient to derive `fibEntry n ∣ fibPeriod n`.