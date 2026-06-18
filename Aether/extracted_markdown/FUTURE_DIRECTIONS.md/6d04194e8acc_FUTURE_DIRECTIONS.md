# Future Directions — Fibonacci Entry Points and the Carmichael Boundary

## Synthesis of this cycle

This cycle closed the open research target `fibEntryPt_mul_coprime` (the **lcm
law** for Fibonacci entry points) inside
`Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`, and then
pushed the entry-point characterization further into a small *arithmetic* of the
entry-point function `α`:

* `fib_mul_dvd_iff_of_coprime` — coprime splitting `a·b ∣ F k ↔ a ∣ F k ∧ b ∣ F k`;
* `fibEntryPt_dvd_of_dvd` — `α` is divisibility-monotone: `a ∣ b ⟹ α a ∣ α b`;
* `fibEntryPt_two = 3`, `fibEntryPt_three = 4` — base values;
* `fibEntryPt_six = 12` — a **structural, non-computational** derivation of the
  Carmichael boundary index `12`, recovering the obstruction recorded in
  `fib_twelve_no_primitive` from the lcm law plus the two base values.

All results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. They sit alongside, and specialise, the abstract strong-divisibility
machinery already in `EntryPointMultiplicativity.lean` (`entry_mul_coprime`,
`entry_dvd_entry_of_dvd`, `dvd_iff_entry_dvd`), turning that generic theory into
explicit numbers and an explicit explanation of why `n = 12` is exceptional.

## Results summary

| Result | Statement | Status |
|---|---|---|
| `fibEntryPt_mul_coprime` | `α(a·b) = lcm(α a, α b)` for coprime `a,b` | proved (was `sorry`) |
| `fib_mul_dvd_iff_of_coprime` | `a·b ∣ F k ↔ a ∣ F k ∧ b ∣ F k` (coprime) | proved |
| `fibEntryPt_dvd_of_dvd` | `a ∣ b ⟹ α a ∣ α b` | proved |
| `fibEntryPt_two`, `fibEntryPt_three` | `α 2 = 3`, `α 3 = 4` | proved |
| `fibEntryPt_six` | `α 6 = 12` (boundary explained) | proved |

---

## Direction 1 — Totality of the rank of apparition (the Pisano existence fact)

Every multiplicative result above and in `EntryPointMultiplicativity.lean`
currently carries an `Appears`/`∃ k, 0 < k ∧ m ∣ F k` hypothesis. Conjecture:
this hypothesis is *always* satisfiable — for every `m ≥ 1` there is a positive
index `k` with `m ∣ F k`, i.e. `Appears Nat.fib m` holds unconditionally.

The key insight is that the Fibonacci recurrence is **invertible modulo `m`**: the
state map `(a,b) ↦ (b, a+b)` on `(ZMod m)²` is a bijection of a finite set, so the
state sequence starting at `(F 0, F 1) = (0,1)` is *purely* periodic; the start
state `(0,1)` therefore recurs, and at the recurrence index `k > 0` we have
`F k ≡ 0`, giving `m ∣ F k`. This is falsifiable: a single `m` with no apparition
index would refute it (none can exist, but the statement is a concrete `∀ m, ∃ k`).

Why now? It is the *only* hypothesis blocking an unconditional, fully closed-form
theory of `α`; discharging it upgrades `fibEntryPt_mul_coprime`,
`fib_entry_mul_coprime`, and `fibEntryPt_dvd_of_dvd` to hypothesis-free theorems
and removes the explicit `Appears` arguments the catalog currently threads
everywhere.

## Direction 2 — A closed form for `α` on prime powers (Wall's question)

With multiplicativity proved, `α(m)` is determined by its values on prime powers.
Conjecture (Wall): for an odd prime `p`, `α(p^e) = p^{e - e₀(p)} · α(p)` where
`e₀(p)` is the largest exponent with `α(p^{e₀}) = α(p)`, and `e₀(p) = 1` for every
prime checked to date. The falsifiable kernel is the **Wall–Sun–Sun** condition
`p² ∣ F(α(p))`, which would force `e₀(p) ≥ 2`.

The key insight is that lifting the exponent in `F` is governed by the `p`-adic
valuation identity `v_p(F(α(p)·t)) = v_p(F(α(p))) + v_p(t)` for `p ∤ t`, an additive
law that, combined with the already-proved lcm law, reconstructs `α` from the
factorization of `m` entirely.

Why now? `fibEntryPt_mul_coprime` reduces the entire problem to prime powers, so a
prime-power formula would complete a computable, proof-checked `α` — exactly the
"compute `α` from the factorization" goal stated in the characterization file's
header.

## Direction 3 — The Carmichael primitive-divisor theorem as `α`-surjectivity

`Shared/CarmichaelProof.lean` still contains one `sorry`: the infinite tail of
`fib_carmichael_composite` (composite `n > 10000`). Conjecture: this tail is
exactly the statement that `α : Primes → ℕ` is **surjective onto** `{n : n ∉
{1,2,6,12}}`, via `entryPt_eq_iff_primitive` (already proved), which recasts
"`F n` has a primitive prime divisor" as "some prime has entry point exactly `n`".

The key insight is that primitivity is `α`-surjectivity: a prime `p` is a
primitive divisor of `F n` iff `α p = n`, so the analytic theorem becomes the
purely structural claim that the primitive part `primPart n` (already defined and
shown `> 1` computationally up to `10000`) exceeds `1` for *all* composite
`n > 12`, which follows from a cyclotomic lower bound `Φ_n(φ,ψ) > 1` on the
homogeneous Fibonacci–cyclotomic factor.

Why now? The entry-point characterization gives the first hypothesis-light bridge
between the computational range in `primPart_check` and the infinite tail; the
remaining gap is a single growth estimate, not the whole theorem.

## Direction 4 — Classifying *all* defective indices from the lcm law

`fibEntryPt_six = 12` shows the boundary case `n = 12` arises because `α 6 = 12`,
i.e. `12` is "used up" as the entry point of the proper divisor `6`. Conjecture:
the complete list of indices `n` with no primitive prime divisor is exactly
`{1, 2, 6, 12}`, and each is detectable by the lcm law alone — `n` is defective iff
every prime factor `p` of `F n` already appears as `α p = lcm(...) < n` forced by
smaller divisors.

The key insight is that defectiveness is a *self-referential lcm collapse*: `n` is
defective precisely when `n` coincides with `lcm` of the entry points of primes
forced by `n`'s proper divisors, leaving no room for a fresh primitive prime —
exactly what `α 6 = 12` exhibits.

Why now? We now have an arithmetic (not merely computational) handle on a defective
index; generalising the `α 6 = 12` argument turns a `native_decide` table into a
finite, human-checkable classification.

## Direction 5 — Transporting the entry-point lattice morphism across sequences

`EntryPointMultiplicativity.lean` already shows the entry map is a divisibility
→ index lattice morphism (`gcd ↦ gcd`, coprime product `↦ lcm`) for *any* strong
divisibility sequence, with Fibonacci and Mersenne (`a^n - 1`) as instances.
Conjecture: every nondegenerate **Lucas sequence** `U_n(P,Q)` with `gcd(P,Q)=1`
is a strong divisibility sequence, so the entire entry-point arithmetic — lcm law,
monotonicity, characterization — transfers verbatim, and elliptic divisibility
sequences satisfy a weakened (gcd-up-to-units) version.

The key insight is that `IsSDS` (`gcd (u m) (u n) = u (gcd m n)`) is the *single*
structural input to the whole theory; proving `IsSDS (U· P Q)` instantly inherits
every theorem proved here for free.

Why now? The abstraction barrier `IsSDS` is already in place and battle-tested on
two sequences; adding Lucas sequences is a high-leverage, low-risk instantiation
that multiplies the catalog's reach into Lehmer-sequence number theory.
