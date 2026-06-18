# Future Directions — The Rank of Apparition as a Lattice Morphism

## Synthesis

This cycle promoted the Fibonacci **spine**
`RankOfApparition.fibRank_dvd_iff : m ∣ F n ↔ fibRank m ∣ n` from a mere biconditional to a
*faithful order/lattice embedding* of moduli (under divisibility) into indices (under
divisibility). The whole point of §7 in
`Catalog/Applications/RankOfApparition.lean` is that everything Fibonacci about apparition is a
corollary of that embedding, proved with zero case analysis and `sorry = 0` (axioms restricted to
`propext / Classical.choice / Quot.sound`).

Two structural facts anchor the cycle:

* **The rank is a join (lcm) morphism.** The keystone is a *universal property*,
  `fibRank_eq_of_forall`: any positive `d` whose multiples are exactly the apparition indices of
  `m` equals `fibRank m`. From it the join law `fibRank_lcm`,
  `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` for positive `a, b`, falls out by feeding
  `Nat.lcm_dvd_iff` through the spine twice. Combined with `fibRank_fib` this gives the closed
  form `fibRank_lcm_fib : fibRank (lcm (F a) (F b)) = lcm a b` for `a, b ≥ 3`, plus the
  hypothesis-free divisibility law `fib_lcm_dvd_fib_lcm : lcm (F a) (F b) ∣ F (lcm a b)`. The
  dual *meet* law is only an inequality, `fibRank_gcd_dvd`.

* **Apparition indices form an exact arithmetic progression.** `card_apparition_Ioc` proves the
  count of apparition indices of `m` in `(0, N]` is *exactly* `N / fibRank m` — an equality for
  every cutoff, not an estimate — and `card_apparition_Ioc_pair` shows the *joint* count of two
  moduli is exactly `N / lcm (fibRank m₁) (fibRank m₂)` **with no error term and no coprimality
  hypothesis**, because the joint apparition set is itself an exact progression.

## Results Summary (`Catalog/Applications/RankOfApparition.lean`, §7)

- `fibRank_eq_of_forall` — universal property: the rank is the unique positive `d` with
  `∀ n, m ∣ F n ↔ d ∣ n`.
- `fibRank_lcm` — join law: `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` for `0 < a, 0 < b`.
- `fibRank_lcm_fib` — `fibRank (lcm (F a) (F b)) = lcm a b` for `a, b ≥ 3`.
- `fib_lcm_dvd_fib_lcm` — `lcm (F a) (F b) ∣ F (lcm a b)` for all `a, b`.
- `fibRank_gcd_dvd` — meet inequality: `fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)`.
- `card_apparition_Ioc` — exact density: `#{ n ∈ Ioc 0 N | m ∣ F n } = N / fibRank m` for `0 < m`.
- `card_apparition_Ioc_pair` — joint exact density:
  `#{ n ∈ Ioc 0 N | m₁ ∣ F n ∧ m₂ ∣ F n } = N / lcm (fibRank m₁) (fibRank m₂)` for `0 < m₁, m₂`.

## Research Directions

### 1. A strictness criterion for the meet (gcd) law

This cycle proves only the inequality `fibRank_gcd_dvd : fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)`.
The natural conjecture is a precise criterion for when it is an *equality*: equality holds iff the
two apparition progressions of `a` and `b` share an index only at common multiples of their ranks
— equivalently, iff no Wall–Sun–Sun-type carry intervenes in `gcd (F (fibRank a)) (F (fibRank b))`.
**The key insight is** that the join law is exact because `lcm a b ∣ F n` decouples into the
*independent* conjunction `a ∣ F n ∧ b ∣ F n`, whereas `gcd a b ∣ F n` does not decouple — so the
gcd defect is exactly the obstruction to that decoupling, a single measurable gcd-of-Fibonacci
correction term. **Why now?** Both sides are computable from this cycle's lemmas
(`fibRank_gcd_dvd`, `fibRank_lcm`, `fibRank_fib`); any counterexample is a finite `#eval`
certificate over a small `fibRank` table, so the criterion is immediately falsifiable.

### 2. Asymptotic density and the natural density limit

`card_apparition_Ioc` and `card_apparition_Ioc_pair` give *exact* finite counts. The next step is
to push these through `N → ∞`: conjecture that the natural density of apparition indices of `m` is
exactly `1 / fibRank m`, and that for any two moduli the joint density is exactly
`1 / lcm (fibRank m₁) (fibRank m₂)` — again with **no error term**. **The key insight is** that
the count `N / fibRank m` is already an equality at every cutoff, so `(N / fibRank m : ℝ) / N →
1 / fibRank m` is a clean squeeze (`|N / d - N/d| < 1`), bypassing every sieve estimate. **Why
now?** The exact counts are in hand; the density statement is a two-line real-analysis limit on
top of them, and it upgrades the discrete progression facts to the analytic-number-theory
vocabulary the next cycle will want.

### 3. Prime-power ranks via Lifting-the-Exponent

Reduce all of `fibRank` to prime powers. Because `fibRank_lcm` factors any modulus through its
prime-power components, the only missing ingredient is the prime-tower recursion
`fibRank (p^(e+1)) = p · fibRank (p^e)` for `e` above the Wall–Sun–Sun threshold. **The key
insight is** that `v_p (F (fibRank p · t))` rises by exactly one each time `t` gains a factor of
`p` — the Fibonacci instance of Lifting-the-Exponent — so the rank's growth on a prime tower is a
single `p`-adic valuation recursion, decoupled from the combinatorics by the spine. **Why now?**
`fibRank_fib` pins exact apparition indices and `fibRank_lcm` reduces composite moduli to
prime-power moduli, so the remaining work is purely the `v_p` recursion, for which Mathlib's
`multiplicity` / `Nat.factorization` API plugs in directly.

### 4. The spine for arbitrary strong divisibility sequences

The §7 proofs used only two facts about `F`: the strong-divisibility law
`gcd (u a) (u b) = u (gcd a b)` (which powers the spine via `Nat.fib_gcd`) and eventual strict
monotonicity. Conjecture that for **any** `u` with `IsStrongDivSeq u` and `u 0 = 0`, every modulus
dividing some `u k` has a rank `rank_u m` with `m ∣ u n ↔ rank_u m ∣ n`, that
`rank_u (u k) = k` past the monotonicity threshold, and that the join law and exact-density count
transport verbatim. **The key insight is** that the entire §7 development is *sequence-agnostic* —
nothing in the lattice or counting arguments touched the Fibonacci recurrence, only the gcd law —
so the spine is a theorem about strong divisibility sequences, not about Fibonacci. **Why now?**
The catalog already proves `fib_isStrongDivSeq` and `mersenne_isStrongDivSeq`
(`Catalog/Applications/StrongDivisibilitySequences.lean`); abstracting the spine instantly yields
entry-point/apparition theory for `aⁿ − 1` (Bang–Zsygmondy) and general Lucas sequences for free.

### 5. Carmichael's composite case from the join law plus a primitive-part bound

This cycle's `fib_prime_index_has_primitive` settles Carmichael's primitive-divisor theorem for
prime indices. For composite `n`, the join law reframes the problem: `fibRank_lcm` and
`fibRank_dvd_of_dvd` describe exactly which earlier `F d` (`d ∣ n`, `d < n`) can share a divisor
with `F n`, so the "primitive part" `F n / ∏_{d ∣ n, d < n} F d` is supported only on the single
prime dividing `n / fibRank`. **The key insight is** that the divisor-lattice bookkeeping that
classical proofs do by hand is now a closed-form consequence of `fibRank_lcm` and
`fib_lcm_dvd_fib_lcm`, reducing the existence of a primitive divisor to a single cyclotomic lower
bound `|Φ_n(φ, ψ)| > n`. **Why now?** With the lattice morphism fully formalised, the remaining gap
is purely an analytic growth estimate (`φ^{totient n}`), which Mathlib supports via
`Nat.totient_lt` and real-power bounds — eliminating any `native_decide` cutoff in favour of a
uniform proof for all large `n`.
