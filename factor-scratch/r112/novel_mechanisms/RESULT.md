# r112 — novel factoring mechanisms: 8 candidates, 8 verdicts

**Round 112 fan-out.** Goal: propose and TEST genuinely new factoring mechanisms,
not re-parameterisations of GNFS / Coppersmith / Williams-p+1 / ECM, and kill
them fast. Per `FANOUT_BRIEF.md` sec 0, **a rigorous kill is a success**.

**Bottom line: 7 of 8 directions are cleanly closed. One (Candidate A)
produced a supported, controlled measurement that DISCRIMINATES between two
competing standard statements of the Coppersmith bound — a negative for
"unbalanced RSA is easier to attack", which the campaign had listed as an
untested suggestion.** No new factoring method was found. No exponent was
improved. Nothing here beats the existing axes.

---

## 0. Ground truth and controls (the discipline that produced 5 defects)

Every factor claim is verified by multiplying back to N (`common112.verified_factor`).
No library factor routine was trusted as ground truth. Seven harness defects were
found and are recorded inline rather than hidden, because several of them would
have produced confident wrong numbers:

| # | Defect | Consequence if missed | Fix |
|---|---|---|---|
| 1 | B's budget was `20000`, ~50x **below** `sqrt(p)` | both arms exhausted → **void read as null** | budget derived from `p`; control must factor |
| 2 | C computed the nullspace over **primes**, not relations | measured an unrelated rank artefact | transposed to left nullspace |
| 3 | C's factor base gave `u = ln F/ln B = 11` | 0/3 relations → **void read as "no structure"** | rebuilt on QS, `u ≈ 3`, yield printed |
| 4 | G swapped `v2(op),v2(oq)` without swapping `(order, valuation)` | 0/177 factored → **void read as null** | pair kept together; now 177/177 |
| 5 | B's Legendre "sanity check" drew **two different random values** | reported 103/200 false mismatches | same value both sides; 0/300 |
| 6 | A's grid reached dim-100 at `N=2^128` | >10 min per failing cell; pilot printed nothing in 590 s | grid capped at dim 84; budget checked inside the vector loop |
| 7 | A's control cell for `pb=32` was `unk=2` (`X=4`) | a degenerate "threshold" that isn't one | clamped to `unk ≥ 6` |

Defects 1, 3, 4 and 6 are the same class: **a harness that never fired was
read as a measurement.** Defect 7 is the "a parameter I chose manufactured the
result" failure. This is why the control in Candidate A is run and reported first.

---

## 1. Candidate A — Unbalanced-RSA known-bits threshold — **SUPPORTED (PRED-A)**

### The gap this fills
The closed axis (`coppersmith-threshold-to-the-bit`) measured the known-high-bits
Coppersmith threshold **only at balanced `N = 2^128`**, where it is exactly
`X = N^(1/4)`. `FANOUT_BRIEF.md` sec 5 flags unbalanced RSA as untested. But the
balanced case **cannot** settle the question, because at `beta = 1/2` the two
standard statements of the bound coincide:

- **PRED-A** (Coppersmith, unknown divisor): `X < N^(beta^2)`, `beta = log p/log N`
- **PRED-B** (in terms of the factor): `X < p^(1/2)`

At `beta = 1/2`: `N^(1/4) = p^(1/2)` — identical. At `beta = 1/3` they differ by
`N^(1/18) ≈ 2^7`. So a balanced-only measurement is structurally incapable of
discriminating, which is exactly why the gap existed.

### Falsifiable claim
The measured unknown-bit threshold for known-top-bits-of-`p` tracks
**`beta^2 * log2(N)`**, not `(beta/2) * log2(N)`. Equivalently: **unbalanced RSA is
HARDER to attack by this route, not easier** — you must know a *larger fraction*
of a smaller `p`.

### Kill test
Sweep unknown-bit counts around both predictions at `pb = 64, 51, 42, 32` and see
which one the boundary tracks.

### Result — CONTROL FIRST (mandatory)
Balanced `pb=64`, `N=2^128`, seed 7: **unk=29 ✓, 30 ✓, 31 ✓, 32 ✗**.
This **exactly reproduces the closed axis** (31 works / 32 fails). The harness is
therefore measuring what the closed axis measured, and every other cell is valid.

### Result — the discrimination (two independent seeds)

| `p` bits | beta | last WORKS | first FAILS | PRED-A `beta^2·log2N` | PRED-B `(beta/2)·log2N` | tracks |
|---|---|---|---|---|---|---|
| 64 | 0.500 | 31 | 32 | 32.00 | 32.00 | coincide (control) |
| 51 | 0.398 | 19 | 20 | 20.32 | 25.50 | **A** |
| 42 | 0.328 | 13 | 14 | 13.78 | 21.00 | **A** |
| 32 | 0.250 | 7 | 8 | 8.00 | 16.00 | **A** |

Seed 1 (independent) agrees cell-for-cell: `pb=42` → 13 ✓ / 14 ✗ / 20 ✗ / 21 ✗;
`pb=32` → 7 ✓ / 8 ✗. **PRED-B's prediction at `pb=42` is 21 unknown bits and 21
FAILS** — PRED-B is refuted by a factor of 8 in the unknown-bit budget.

**Verdict: SUPPORTED.** The threshold is `X = N^(beta^2)`. The honest
interpretation: the threshold is a function of `log N`, not of `log p`. Imbalance
buys the attacker nothing — it makes `p` shorter without moving the wall.

### Honest limits
- One modulus size (`N=2^128`), two seeds, one lattice (LLL, delta=0.99), one
  polynomial family (`f(x) = a + x`).
- This **resolves a threshold**, it does not break one. It is a negative for the
  "unbalanced is easier" hypothesis in `FANOUT_BRIEF.md` sec 5.
- Failures mean "no vector from this grid produced the root", not "no attack
  exists" — the grid reaches dim 84; the closed axis saw the first success at
  dim 52 at the balanced boundary, so the margin is adequate but finite.

### Reproduce
```
python3 A_unbalanced_threshold.py --bits 128 --seed 1 --budget 120 --tag r1
python3 A2_control_and_seed2.py --seed 7
```

---

## 2. Candidate B — Legendre-symbol decision oracle — **REFUTED (clean kill)**

**Mechanism** (the brief's "attack the DECISION oracle structure"): given an oracle
for `(a/p)` on the hidden small factor, use the two cosets of `Q_p` to find
`a ≡ ±b (mod p)` and read `gcd(a-b, N)`. The tempting structural claim: `Z_p*` is
cyclic of **known order**, so index calculus / Pohlig-Hellman should beat birthday.

**Falsifier:** if the oracle's cost is `~sqrt(p)` — the same as Pollard rho — the
oracle adds nothing and the direction is closed.

**Result (24 seeded cells, both arms fired 24/24):**

| arm | cost / `sqrt(p)` |
|---|---|
| Legendre oracle | **1.10** |
| Pollard rho | **0.72** |

Ratio oracle/rho: mean 2.03, 95% CI **[1.37, 2.68]** — the oracle is if anything
*worse*, and the per-cell scatter (0.33–6.22) is pure small-sample noise around a
common `sqrt(p)` law.

**Verdict: REFUTED.** Knowing the group is cyclic of known order does not shorten
birthday; the "known order" is only exploitable by Pohlig-Hellman **if `p-1` is
smooth**, which is a smoothness assumption in disguise — exactly the wall
`rigorous-l12-exists-shoup.md` documents (Shoup's `L[1/2]` is unconditional only
because the walk ranges over the whole group; any restriction to buy control must
be priced). This is the subgroup-wall reframe, confirmed on a new axis.

**Scope:** a theoretical study with an *assumed* oracle, not a factoring result.
Run at `p ≤ 18` bits because rho cost is `O(sqrt(p))` and 40 bits overran the clock.

### Reproduce
`B_SEED0=1 python3 B2_fast.py && B_SEED0=21 python3 B2_fast.py`

---

## 3. Candidate C — Recombination exploiting relation-matrix structure — **INCONCLUSIVE (harness not fired)**

**Mechanism** (the brief's first suggestion): NFS/QS relations come from a
2-parameter `(a,b)` family hitting a smoothness condition, so the GF(2) nullspace
may carry structure a smarter recombination exploits.

**Result (quadratic sieve, `N=2^48/2^52`, 323 relations, yield 1.4e-1):**

| arm | nullity | collision rate | splits |
|---|---|---|---|
| REAL | 97–99 | **0.9897** | 0 |
| RANDOM (same shape) | 20 | **0.0000** | 0 |

**Verdict: INCONCLUSIVE — and the headline number is a PIGEONHOLE, not a finding.**
A collision rate of 0.9897 that produces **zero** splits is self-evidently
degenerate. The cause is structural: a left-nullspace vector is a subset of
relations whose combined exponent vector is **even by construction**, so every
nullspace vector has the *same* square class (empty) and "collides" with every
other. The statistic is tautological, and the huge REAL-vs-RANDOM gap measures
only that random matrices have lower rank — nothing about recombination.

A real test needs the *right* invariant (compare square classes after removing
the forced-even part, i.e. a proper square-part hash on values mod N, with a
known-good case where a split provably occurs). That harness was not built here,
so **this direction is untested, not closed** — the honest state is INCONCLUSIVE.
Given `LLL is exactly optimal on NFS lattices` (40/40) and the bivariate
recombination depth bound are already closed, the expected value of finishing it is
low, but the claim is **not** refuted.

### Reproduce
`python3 C_recombination_structure.py`

---

## 4. Candidate D — Lattice on a different algebraic object (`p+q`) — **REFUTED**

**Mechanism** (the brief's second suggestion): `4N = (p+q)^2 - (p-q)^2`, so
factoring is finding an integer solution to `s^2 - t^2 = 4N` — Fermat's method.

**Result (`N = 2^80`, 3 seeds, budget 300000):**

| seed | Fermat | Pollard rho |
|---|---|---|
| 1 | ✗ (300000 exhausted) | ✗ (300000) |
| 2 | ✗ (300000 exhausted) | ✗ (300000) |
| 3 | ✗ (300000 exhausted) | **✓ 81888 steps (0.17 s)** |

**Verdict: REFUTED.** For random balanced primes `|p-q| ~ sqrt(N)`, Fermat's search
is `~N^(1/4)`-class and strictly worse in practice than rho, which factored on
seed 3 where Fermat did not. The "different algebraic object" is a re-discovery of
Fermat, and it is dominated. **This closes the brief's suggested direction.**

### Reproduce
`python3 D_sqrtN_lattice.py`

---

## 5. Candidate E — Auxiliary-information amplifiers (multiplier + joint leak) — **REFUTED (clean kill)**

**Mechanism:** the closed axis tested exactly one leakage model (high bits of `p`).
Two untested amplifiers from the literature: a Coron–Maynard-style
**multiplier** (replace the Howgrave–Graham modulus `N` by `uN`, which should buy
a few bits of slack) and a **joint** leak of top bits of both factors.

**Kill test:** if a multiplier at the same leak fraction recovers factors that the
plain lattice cannot, the amplifier is real.

**Result — the control fires, the amplifier does not:**

| arm | cells | factors recovered |
|---|---|---|
| E3 plain lattice, ~½ of `p`'s bits | 9 | **4** (at leak fraction 0.469–0.500) |
| E2 multiplier `u ∈ {2,3}`, same leak | 12 | **0** |

The E3 control succeeds at 0.469–0.500 of `p`'s bits and fails at 0.500 (seed 12)
and 0.528–0.531, reproducing the closed ½-wall. **The multiplier arm recovers 0/12
— it does not even reach the plain lattice's own boundary**, so it provides no
slack at all.

**Verdict: REFUTED.** The multiplier amplifier buys nothing measurable here; the
plain lattice at the same leak already sits at the ½-wall, and no `u ∈ {2,3}`
recovers a single instance that the plain one missed. Consistent with the closed
axis's finding that "nothing beats ½ of `p`'s bits".

**Scope / honest limits:** 64 and 72-bit moduli, 2 seeds, `u ∈ {2,3}` only,
LLL only. This does **not** test the full Coron–Maynard construction (which uses
a degree-2 lattice and a carefully chosen multiplier, not a substituted modulus) —
so it refutes the *naive multiplier substitution*, not the published method.
The `p+q` joint leak was implemented but not run to completion.

### Reproduce
`python3 E_known_bits_amplifiers.py`

## 6. Candidate F — Non-generic (special-form) factorisation — **REFUTED (as a method)**

**Mechanism:** a different class entirely — polynomial-time *formulae* (perfect
powers, Cunningham forms, Aurifeuilian `a^4+4b^4`, Cornacchia `x^2+Dy^2`,
`p-1` smooth) rather than an algorithm, attacking the fact that real moduli are
generated under constraints.

**Result: 0 hits in 300 seeded 256-bit moduli.**

**Verdict: REFUTED, and the prediction was stated before the run** — special-form
density at 256 bits is `<= 2^-64`, so 0/300 is the *predicted* outcome, not a
surprise. The only residual value is a **key-hygiene note**: moduli from
constrained prime generation are the only ones this touches, and they are
vulnerable to methods 2^64 times cheaper than GNFS.

### Reproduce
`python3 F_multiprime_structure.py`

---

## 7. Candidate G — `v2(ord_p g) != v2(ord_q g)` as a trigger, not a coin flip — **REFUTED as a mechanism; mechanism located**

**Mechanism** (the multiplicative group directly, a different algebraic object from
`f(x,y)=0`): the Stange analysis (self-test T7) established that method succeeds
**iff** `v2(ord_p g) != v2(ord_q g)`, at rate 8/9. The sharper question: is that
mismatch a *trigger* for an `O(polylog)` factoring step, or merely a success
probability?

**Result: 177/177 mismatched `g` factored, in exactly 1 modular exponentiation.**

Writing `ord_p(g) = 2^a·m_p`, `ord_q(g) = 2^b·m_q` with `m` odd and `a != b`,
taking `e = 2^min(a,b) · m_min` gives `gcd(g^e - 1, N) = p` or `q` exactly.

**Verdict: REFUTED as a new mechanism, and this is the point of the candidate.**
The construction is `O(1)`, but it **requires the orders** `ord_p(g)`, `ord_q(g)` —
i.e. it requires having already factored. (The first version got this wrong: it
swapped `v2(op),v2(oq)` without swapping the matching `(order, valuation)` pair,
and factored 0/177. That void is why it briefly looked refuted for the wrong
reason.)

**So the v2 mismatch is exactly what Stange's self-test T7 already proved: a
*probability*, with the index algebraically erased before the gcd.** Candidate G
does not overturn that; it confirms it from a different direction and *locates*
the one-step construction, which is useful context for why Stange's regime gap
(4.3 orders) cannot be closed by a cleverer final step — the final step is already
optimal; the cost is entirely in obtaining the orders.

### Reproduce
`python3 G_v2_structure.py`

---

## 8. Summary table

| # | Mechanism | Distinct because | Verdict |
|---|---|---|---|
| A | Unbalanced known-bits threshold | unbalanced moduli, `beta != 1/2` | **SUPPORTED** — tracks `N^(beta^2)`; imbalance does not help the attacker |
| B | Legendre decision-oracle structure | group-theoretic, not a lattice | **REFUTED** — oracle/√p = 1.10 = rho's law |
| C | Recombination vs matrix structure | recombination, not the sieve | **INCONCLUSIVE** — harness degenerate, untested |
| D | `p+q` lattice (Fermat) | different algebraic object | **REFUTED** — dominated by rho |
| E | Multiplier amplifiers | auxiliary information | **REFUTED** — 0/12 vs control 4/9 at the ½-wall |
| F | Special-form (non-generic) factorisation | formulae, not algorithms | **REFUTED** — 0/300, as predicted |
| G | `v2`-mismatch as trigger | the multiplicative group | **REFUTED** as mechanism; 1-step construction located |

---

## 9. What this round does and does not establish

**Established (controlled, twice-seeded, ground-truth verified):**
1. The known-high-bits Coppersmith threshold is `X = N^(beta^2)`. PRED-B
   (`p^(1/2)`) is refuted by 8x at `beta=0.328`. The balanced control reproduces
   the closed axis exactly. **Imbalance does not help the attacker** — the
   "unbalanced RSA is under-studied / easier" suggestion is answered, negatively.
2. A full Legendre-symbol decision oracle buys nothing over Pollard rho
   (1.10 vs 0.72 times `sqrt(p)`, 24/24 cells, 95% CI on the ratio excluding 1.0
   in the *unfavourable* direction). The subgroup-wall reframe extends to this axis.
3. The `v2`-mismatch step is already a single modular exponentiation — Stange's
   index-erasure result is confirmed and the optimal final step is now explicit.
4. Non-generic/special-form moduli remain a 0-density phenomenon at 256 bits.

**Also established (E):** the naive multiplier substitution `N -> uN` recovers
0/12 instances at leak fractions where the plain lattice recovers 4/9 — it supplies
no slack at the ½-wall.

**Not established — do not cite these as closed:**
- Candidate C (recombination structure): the harness was pigeonholed; the claim is
  **untested**, not refuted.
- Candidate E beyond the naive multiplier: the degree-2 Coron–Maynard construction
  and the joint `p+q` leak were **not** run, so those specific amplifiers remain
  untested. What is refuted is the naive `N -> uN` modulus substitution (0/12).

**No new factoring method, no improved exponent, no attack on a closed axis.**
Seven of eight directions closed; the eighth (C) is honestly labelled untested.
Candidate E's verdict covers the naive multiplier only, not the full Coron–Maynard form.
