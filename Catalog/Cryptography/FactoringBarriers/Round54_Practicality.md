# Round 54 — the deterministic exponent is not the practical frontier, and that reorders everything

**2026-10-03. No new factoring algorithm. But one check I should have run in
round 49, which changes what the next five rounds should be about, and one
negative result on a very recent paper.**

Empirical: `_scratch/r49/{practicality,prime_enum}.py`.

---

## 1. The check I should have run first

Five rounds have chased the deterministic exponent: `N^{1/5}` (Harvey 2021) and
the target `N^{1/6}`. **Before spending more effort there: is that bound ever the
one you would actually run?**

| bits | Harvey `N^{1/5}` (lg₂ s) | GNFS `L[1/3,1.923]` (lg₂ s) | faster |
|---|---|---|---|
| 128 | 25.6 | 33.7 | Harvey |
| 200 | 40.0 | 41.6 | Harvey |
| **215** | **43.0** | **43.0** | **crossover** |
| 256 | 51.2 | 46.7 | GNFS 1.10× |
| 1024 | 204.8 | 86.8 | GNFS 2.36× |
| 2048 | 409.6 | 116.9 | GNFS 3.50× |

**They cross at ≈215 bits.** Above that GNFS is faster by an unbounded factor —
3.5 orders of magnitude at 2048 bits. And this is not close: the reason is
structural. `N^{1/5}` is **exponential in the bit length** (`0.2·b` bits of work);
`L_N[1/3,c]` is **subexponential in the bit length** (`≈ b^{1/3}` bits of work).
The deterministic bound is asymptotically *and* practically dominated.

**Harvey's `N^{1/5}` appears in no practical factoring pipeline.** GNFS has
factored RSA-250 (829 bits) and RSA-260 (862 bits, i.e. 260 decimal digits);
ECM records are 80–90 bits;
deterministic methods are used only to strip *small* factors (Pollard p−1, ECM,
trial division).

> **[Round 58 correction.]** The sentence above originally read *RSA-260 (872
> bits)*. That is wrong — 260 decimal digits is **862** bits. Corrected in place.
> I introduced the error by writing the bit count from memory instead of
> computing `⌈260·log₂10⌉`.

**This does not say `1/5` is unimportant.** It is the right notion for an
*adversary* — a deterministic algorithm is a proof that no assumption is needed,
and `1/5 → 1/6` is a real mathematical advance. Umans–Wang are pursuing
something genuine.

**But it does say the next round should not be a sixth re-derivation of a
deterministic cost model.** And it retro-explains Round 52: the reason four terms
tie at `N^{1/5}` is that the entire regime is asymptotically irrelevant, so the
over-determination is an artefact of a self-consistent analysis nobody needs,
rather than a real resource constraint. I presented that as a sharpening; it is
sharper than I thought, and in a direction that de-emphasises the result.

---

## 2. A recent paper that does *not* help: Harvey, "Faster enumeration of primes"

arXiv:2606.22851 (22 June 2026) — first-ever speedup by a positive power of
`log N` over the sieve of Eratosthenes; `N(log log N)^{1+o(1)}` bit operations
(not fully rigorous), with rigorous Las Vegas and deterministic variants.

This is a genuinely striking result, and the first thing to check is whether it
touches any factoring bound. **It does not, and the reason is clean.**

Every subexponential factoring method uses a factor base of size `L[a,c]` with
`a < 1` — exponentially smaller than `N`:

| bits | GNFS base `B = L[1/3,c/3]` | `B/N` |
|---|---|---|
| 256 | 4.81e4 | 4.2e−73 |
| 512 | 2.60e6 | 1.9e−148 |
| 1024 | 5.09e8 | 2.8e−300 |

So prime enumeration to `B` is already negligible next to every other cost. A
`log N` speedup there is worth nothing at the exponent level. Concretely, Harvey's
own `N^{1/5}` never enumerates primes at all (his factor base is an
`α`-power table, and the small-factor test is a Strassen product tree), so his
own new result does not touch his own factoring algorithm.

*(One correction to my own script, recorded because it is the same failure mode
as Round 52 §3: my first version printed `log2(L_N[1/3,c])` as if `L` were the
time, giving values like `6.3` at 2048 bits and a spurious 64× gap. `L` is
`exp(...)`, so its `log2` is `≈ b^{1/3}`. Fixed before drawing any conclusion.)*

---

## 3. Reordering the project

| axis | status after six rounds |
|---|---|
| `N^{1/5}` → `N^{1/6}` | real open problem; Umans–Wang conditional. But **crossover at 215 bits** — asymptotic, not practical |
| order subroutine | closed (R50) — Jan 2026 dropped the hypothesis, buys nothing |
| small-factor test | closed (R52) — already free via ECM |
| `L_n[1/2,c]`, `c<1` | closed (R53) — `c=1` optimal rigorous *and* heuristic |
| prime enumeration | closed (this round) — new speedup, no factoring consequence |
| **`L_n[1/3,c]`, the constant** | **open, and the only axis with practical headroom** |

The last row is now the clear priority. Rigorous NFS machinery exists
(arXiv:2007.02689; Buhler–Lenstra–Pomerance); the exponent `1/3` is achieved; the
**constant** is what is unproven. GNFS's heuristic constant is `1.923`, and
Round 53 established that `1/3` is the smoothness barrier, so all remaining
freedom on this axis is the constant.

---

## 4. Verdict

**No new factoring algorithm. No exponent improvement.** Round 54 produced:

1. **A practicality check that should have come first** (§1): `N^{1/5}` and GNFS
   cross at ≈215 bits; beyond it the deterministic record is never the tool you
   would use. This reorders the remaining work.
2. **A closed question** (§2): Harvey's June-2026 prime-enumeration speedup has no
   factoring consequence, for a structural reason (factor bases are
   exponentially smaller than `N`).
3. **A corrected target**: rigorous `L_n[1/3,c]`, the constant.

**Honest assessment of six rounds.** What I have produced: a verified frontier
map including the January and June 2026 papers; a simplification of the Umans–Wang
chain (Round 49, prefactorisation is unnecessary); a sharp negative result on the
consecutive-AP route and on re-indexing the Lehman pairs (Rounds 49, 51); the
observation that the `N^{1/5}` optimum is pinned by three independent terms
(Round 52); the closure of the `L[1/2,c]` gap (Round 53); and now the practicality
reordering.

**None of it beats any existing complexity bound.** What it does is remove five
plausible-looking targets, which is a real if unglamorous contribution — and the
practicality check in §1 is the single most decision-relevant result, because it
says the deterministic contest, which I spent five rounds on, is the wrong one.

**Next.** Rigorous `L_n[1/3,c]`. The question is concrete: **is there a rigorous
lower bound on the number of `B`-smooth values in the GNFS sieving region sharp
enough to pin the constant?** Rankin's bound gives the heuristic constant; what
has been proved is weaker. If that gap can be closed, `L_n[1/3,1.923]` becomes
rigorous — which would not be faster than anything, but would remove the last
heuristic assumption from the only factoring algorithm anyone actually runs. I
have no mechanism for it and I am not going to pretend otherwise.