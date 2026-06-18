# Future Directions — The Rank of Apparition as a Lattice Morphism

## Synthesis

The previous cycle distilled Fibonacci apparition theory down to a single **spine**,
`RankOfApparition.fibRank_dvd_iff : m ∣ F n ↔ fibRank m ∣ n` (primitivity-free), together with
the exact rigidity `fibRank_fib : fibRank (F k) = k` for `k ≥ 3`. This cycle exploits the spine
in two new directions, both proved from scratch in `Catalog/Applications/RankOfApparition.lean`
(§7), with `sorry = 0` and axioms restricted to `propext / Classical.choice / Quot.sound`:

* **The rank is a join (lcm) morphism of divisibility lattices.** The keystone is a *universal
  property*, `fibRank_eq_of_forall`: any positive `d` whose multiples are exactly the apparition
  indices of `m` equals `fibRank m`. From it the join law `fibRank_lcm`,
  `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` for positive `a, b`, falls out by feeding
  `Nat.lcm_dvd_iff` through the spine twice — no case analysis. Combined with `fibRank_fib` this
  gives the closed-form evaluation `fibRank_lcm_fib : fibRank (lcm (F a) (F b)) = lcm a b` for
  `a, b ≥ 3`, collapsing the catalog's two parallel rank objects (`fibEntry`, `fibRank`) into one
  concrete computation, plus the hypothesis-free divisibility law
  `fib_lcm_dvd_fib_lcm : lcm (F a) (F b) ∣ F (lcm a b)`.

* **Apparition indices form an exact arithmetic progression.** `card_apparition_Ioc` proves that
  the apparition indices of `m` in `(0, N]` number *exactly* `N / fibRank m` — an equality for
  every cutoff, not an asymptotic estimate, obtained by transporting the count of multiples
  (`Nat.Ioc_filter_dvd_card_eq_div`) across the spine.

The unifying lesson: the spine is not merely a biconditional but a faithful order/lattice
embedding of moduli (under divisibility) into indices (under divisibility). Everything Fibonacci
about apparition is a corollary of that embedding.

## Results Summary (`Catalog/Applications/RankOfApparition.lean`, §7)

- `fibRank_eq_of_forall` — universal property: the rank is the unique positive `d` with
  `∀ n, m ∣ F n ↔ d ∣ n`.
- `fibRank_lcm` — join law: `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` for `0 < a, 0 < b`.
- `fibRank_lcm_fib` — `fibRank (lcm (F a) (F b)) = lcm a b` for `a, b ≥ 3`.
- `fib_lcm_dvd_fib_lcm` — `lcm (F a) (F b) ∣ F (lcm a b)` for all `a, b`.
- `card_apparition_Ioc` — exact density: `#{ n ∈ Ioc 0 N | m ∣ F n } = N / fibRank m` for `0 < m`.

## Research Directions

### 1. The meet (gcd) law and exactly when it is strict

`fibRank_dvd_of_dvd` already forces `fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)` (apply
monotonicity to `gcd a b ∣ a` and `gcd a b ∣ b`). The dual of the clean join law would be
equality, `fibRank (gcd a b) = gcd (fibRank a) (fibRank b)`, but this *fails* in general (the
spine only linearizes lcm, not gcd, because two moduli can share an apparition index without
sharing a common divisor). The falsifiable conjecture is a precise strictness criterion: equality
holds iff `gcd (F (fibRank a)) (F (fibRank b)) = F (gcd (fibRank a) (fibRank b))` is "tight", i.e.
iff no Wall–Sun–Sun-type carry intervenes. **The key insight is** that the join law is exact
because `lcm a b ∣ F n` decouples into an *independent* system of index-divisibilities, whereas
`gcd a b ∣ F n` does not decouple — so the gcd defect is exactly the obstruction to that
decoupling, measurable as a single gcd-of-Fibonacci correction term. **Why now?** Both sides are
already computable from this cycle's lemmas (`fibRank_dvd_of_dvd`, `fibRank_lcm`), so the
conjecture is immediately testable against a `#eval` table of `fibRank` and any counterexample is
a finite certificate.

### 2. Multiplicative density across coprime moduli

`card_apparition_Ioc` gives the exact one-modulus count `N / fibRank m`. Conjecture the coprime
refinement: for `Nat.Coprime m₁ m₂`, the joint apparition count
`#{ n ∈ Ioc 0 N | m₁ ∣ F n ∧ m₂ ∣ F n }` equals `N / lcm (fibRank m₁) (fibRank m₂)`, and hence
the natural density factorises as `1 / fibRank m₁ · 1 / fibRank m₂ · gcd(...)`-corrected. **The
key insight is** that `m₁ ∣ F n ∧ m₂ ∣ F n ↔ lcm m₁ m₂ ∣ F n`, so by `fibRank_lcm` the joint set
is again an *exact* progression of step `lcm (fibRank m₁) (fibRank m₂)` — densities therefore
multiply across coprime moduli with **no error term**, unlike classical sieve density arguments.
**Why now?** The single-modulus exact count and the join law are both in hand this cycle; the
joint statement is a two-line composition (`Nat.lcm_dvd_iff` then `card_apparition_Ioc`), making
it a near-term provable target rather than a heuristic.

### 3. Prime-power ranks via Lifting-the-Exponent

Reduce all of `fibRank` to prime powers. Conjecture `fibRank (p^(e+1)) = p · fibRank (p^e)` for
`e ≥ E₀(p)`, where `E₀(p)` is the Wall–Sun–Sun threshold (`E₀(p) = 1` for every known prime).
**The key insight is** that `v_p (F (fibRank p · t))` rises by exactly one each time `t` gains a
factor of `p` — the Fibonacci instance of Lifting-the-Exponent — so the rank's growth on a prime
tower is governed by a single `p`-adic valuation recursion, decoupled from the combinatorics by
the spine. **Why now?** `fibRank_fib` pins exact apparition indices and `fibRank_lcm` reduces
composite moduli to prime-power moduli via factorisation, so the only remaining ingredient is the
`v_p` recursion, for which Mathlib's `multiplicity` / `Nat.factorization` API and the catalog's
existing LTE-for-Fibonacci development can be plugged in.

### 4. The spine for arbitrary strong divisibility sequences

The proofs of `fibRank_dvd_iff`, `fibRank_fib`, `fibRank_lcm`, and `card_apparition_Ioc` used only
two facts about `F`: the strong-divisibility law `gcd (u a) (u b) = u (gcd a b)` and eventual
strict monotonicity. Conjecture that for **any** `u` with `IsStrongDivSeq u` and `u 0 = 0`, every
modulus dividing some `u k` has a rank `rank_u m` with `m ∣ u n ↔ rank_u m ∣ n`, that
`rank_u (u k) = k` past the monotonicity threshold, and that the join law and exact-density count
transport verbatim. **The key insight is** that the entire §7 development is *sequence-agnostic* —
nothing in the lattice or counting arguments touched the Fibonacci recurrence, only the
gcd-law — so the spine is a theorem about strong divisibility sequences, not about Fibonacci.
**Why now?** The catalog already proves `fib_isStrongDivSeq` and `mersenne_isStrongDivSeq`;
abstracting the spine instantly yields entry-point/apparition theory for `aⁿ − 1` (Bang–Zsygmondy)
and general Lucas sequences for free, a genuine cross-file unification of the number-theory corpus.

### 5. Carmichael's composite case from the join law plus a primitive-part bound

This cycle's `fib_prime_index_has_primitive` settles Carmichael for prime indices. For composite
`n`, the join law reframes the problem: `fibRank_lcm` and `fibRank_dvd_of_dvd` describe exactly
which earlier `F d` (`d ∣ n`, `d < n`) can share a divisor with `F n`, so the "primitive part"
`F n / ∏_{d ∣ n, d < n} F d` is supported only on the single prime dividing `n / fibRank`.
**The key insight is** that the divisor-lattice bookkeeping that classical proofs do by hand is
now a closed-form consequence of `fibRank_lcm` and `fib_lcm_dvd_fib_lcm`, reducing the existence
of a primitive divisor to a single cyclotomic lower bound `|Φ_n(φ, ψ)| > n`. **Why now?** With the
lattice morphism fully formalised, the remaining gap is purely an analytic growth estimate
(`φ^{totient n}`), which Mathlib supports via `Nat.totient_lt` and real-power bounds — eliminating
the catalog's `native_decide` cutoff at `n ≤ 50000` in favour of a uniform proof for all large `n`.
