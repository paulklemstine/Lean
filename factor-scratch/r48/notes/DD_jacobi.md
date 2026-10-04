# DD — the Jacobi-symbol Cayley graph: can the degree be *estimated*?

**Target.** `S = {x ∈ Z/nZ : (x/n) = +1}`, the Paley-type Cayley graph
`Cay(Z/nZ, S)`, whose adjacency matrix is polylog-computable (each entry is one
Jacobi symbol) and whose degree is `deg = |S| = φ(n)/2 = (n+1−p−q)/2`, so
`p + q = n + 1 − 2·deg`. The census (`H_crossdiscipline.md` §9.1) recorded this
as *"the round's only genuinely live lead … I'd bet against it."*

**Question.** Can `deg` be estimated — not exactly computed — to an accuracy that
factors `n`?

**Answer: no, and not by a small margin.** The lead is closed. The kill is
structural and needs one line, not a cost measurement — but the derivation of
that line required fixing the brief's bound, which was wrong.

---

## 0. Corrections to the brief that the work turned up

**0.1 — the precision bound in the brief is wrong, and wrong in the dangerous
direction.** The brief asks about `ε < (p−q)²/8`. The exact
necessary-**and**-sufficient demand is

> ### ★★ ε\* = (2|p−q| − 1) / (4(p + q + |p−q| − 1)) = (2g−1)/(8·max(p,q) − 4),  g = |p−q|

*Derivation.* With `s̃ = s − 2ε` (the branch that shrinks `s`), put `g = q−p`,
`S = p+q`, and `r = √(s̃² − 4n)`, so `r² = g² − 4εS + 4ε²`. The two roots of
`X² − s̃X + n` move by

```
q̃ − q = (r − g − 2ε)/2 ,      p̃ − p = (g − r − 2ε)/2 ,      A := g − r ≥ 0 ,
```

and the binding constraint is `|q̃ − q| < ½`, i.e. `A + 2ε < 1`, i.e.
`r > g − 1 + 2ε`. Squaring (both sides positive for `g ≥ 2`) gives
`4ε(S + g − 1) < 2g − 1`. The opposite branch gives `(2g+1)`; the smaller is
binding. For balanced `p,q` this is `ε* ~ g/(4√n)` — the brief's first-order
`(p−q)²/8` is too **loose** by a factor `~ |p−q|·max(p,q)/2`.

**Verified by bisection, not asserted** (`self_test.py` ST7). Empirical breaking
point ÷ prediction, 7 cases, `n` from 15 to 10¹²:

| n | \|p−q\| | ε\* predicted | ratio (measured/predicted) |
|---|---|---|---|
| 15 | 2 | 8.333333e−02 | 1.00000000 |
| 10403 | 2 | 3.658537e−03 | 1.00000000 |
| 100160063 | 2 | 3.746815e−05 | 1.00000000 |
| 4295229443 | 2 | 5.721828e−06 | 1.00000127 |
| 10969629647 | 14 | 3.222188e−05 | 0.99999997 |
| 1000036000099 | 30 | 7.374760e−06 | 0.99999670 |
| 999985999949 | 20 | 4.874988e−06 | 0.99999220 |

Worst relative deviation **7.8e−6**, and that is resolution-limited by the
rational denominator used in the bisection, not by the bound. (The **tightest
case**, `g = 2`, is in the table precisely because that is where the `−1`
corrections dominate and where a loose bound would most easily be mistaken for
a correct one.)

*How much too loose is the brief's bound?* Applying `ε` just under
`(p−q)²/8` **fails to factor in 6 out of 6 test cases** (ST4.2). Ratios
`bound_task/ε*`: **6×, 137×, 1.33e4×, 8.74e4×, 7.6e5×, 1.53e7×, 1.03e7×.** Had
this round adopted the brief's bound, it would have certified a method that
provably does not work — the same failure mode as the `int(n**(1/3))` incident,
with the same "test at the tightest case" remedy.

**0.2 — `deg = φ(n)/2` needs `n` squarefree.** At `n = p²` the degree is
**`φ(n)`**, not `φ(n)/2`, because `(x/p^e) = (x/p)^e` and the exponent 2 is
even, so the symbol is `+1` on *every* unit. Measured over all residues:

| n | 25 | 9 | 121 |
|---|---|---|---|
| deg | 20 | 6 | 110 |
| φ(n)/2 | 10 | 3 | 55 |
| φ(n) | **20** | **6** | **110** |

Harmless for the `n = pq` target, but the census stated the identity without the
hypothesis.

**0.3 — even `n` is fine, contra my first draft.** I initially claimed the
construction is *undefined* for even `n`. **That was wrong and is withdrawn.**
Under the Kronecker extension `(a/n) = (2/m)^k (a/m)` for `n = 2^k m`, it *is* a
character (for `n ≡ 2 mod 4`), and `deg = φ(n)/2` survives — verified over all
residues for `n = 6, 14, 22, 202, 1994, 209458`, each recovering `p+q` exactly.
So even RSA moduli `n = 2q` are covered by the same identity.

---

## J1 — the sampling bound. **VERDICT: dead, and strictly.**

The estimator is `deg̃ = n · mean(1[(x/n)=+1])` over uniform residues, each
evaluated by one factorization-free Jacobi symbol. With `ρ = deg/n → ½`,

```
k* = ( n·√(ρ(1−ρ)) / ε )²   and   √(ρ(1−ρ)) ≤ ½   ⟹   k* ≥ (n/(2ε))² .
```

**★ And `ε* < ½` for every prime pair** (proof in J3; `g < S` ⟹ `2g−1 < 2S−1 <
2(S+g−1)` ⟹ `ε* < ½`). Therefore

> ### ★★ k\* > n²  for every prime pair — balanced or not, no asymptotics needed.

The estimator needs **more than `n²` samples just to reach a precision that
turns out to be sub-integer**. It cannot even match the `Θ(n)` enumeration the
census had already dismissed. Measured, fixed `n = 1000003·1000033`:

| \|p−q\| | 2 | 30 | 10⁴ | 10⁶ | 10⁷ |
|---|---|---|---|---|---|
| k\* | 1.78e36 | 4.60e33 | 4.04e28 | 1.05e25 | 4.08e24 |
| k\*/n | 1.8e24 | 4.6e21 | 4.0e16 | 1.0e13 | 4.1e12 |

**(a) Random `p, q`.** `g ~ √n ⟹ ε* ~ ¼ ⟹ k* ~ 4n²`. The brief's guess
("hopeless for random semiprimes") is **confirmed**, and for a reason `~n` times
harsher than the brief's own bound implies.

**(b) Close primes — the regime the brief hoped would work.** At the Cramér gap
`g ~ √n log n`, `k* ~ 4n²/log²n`, so `k*/n = 4n/log²n` is still **linear in `n`**.
**Closeness rescues nothing** — it buys only a logarithmic factor. And the
regime is not merely unimproved, it is **strictly dominated by Fermat**:

| n | p | q | \|p−q\| | k\* | Fermat steps |
|---|---|---|---|---|---|
| 10000007600001443 | 100000037 | 100000039 | 2 | 1.78e48 | **0** |
| 100000980001501 | 10000019 | 10000079 | 60 | 1.13e39 | **0** |
| 1000036000099 | 1000003 | 1000033 | 30 | 4.60e33 | **0** |
| 10969629647 | 104729 | 104743 | 14 | 2.90e28 | **0** |

Every deliberately-close pair is factored by Fermat in **zero** increments while
sampling needs 10²⁸–10⁴⁸ samples. So: **yes, this is a rediscovery of Fermat's
method — and a loss of 36 orders of magnitude inside Fermat's own regime.**
That answers the brief's "check whether this is just a rediscovery of Fermat's
method": it is, and it is worse.

The convergence law underpinning all of this is **measured**, not assumed
(ST6, 3000 seeds per `k`, three decades): `E|err| = √(2/π)·n·√(ρ(1−ρ)/k)` with
`ρ = ½`, fitted global log-log slope **−0.5021** over `k ∈ [10³, 10⁶]`, constant
matching to within 1.5%.

---

## J2 — is there structure to exploit? **VERDICT: no — and the negative is stronger than the census's.**

**The count factorises, exactly as the brief feared:**

```
deg = #{(a,b) : (a/p)(b/q) = +1} = 2·⌊(p−1)/2⌋·⌊(q−1)/2⌋ = φ(p)φ(q)/2 = φ(n)/2
```

verified over **all** residues for `p,q ∈ {(3,5),(5,11),(7,13),(101,103),(997,1009),(1021,1031)}`.
**This is a restatement**, stated as such. And the brief's premise that *"each
factor is easy"* is **false**: evaluating `(p−1)/2 mod m` needs `p mod 2m`,
i.e. needs `p`. Neither side of the CRT split is computable without the factor
it hides. So there is no sub-`n` exact algorithm for the product count — not
because it is hard, but because it is `φ(n)/2` written twice.

**The spectral question, and a self-correction.** I predicted the whole non-trivial
spectrum would be polylog-computable (the Ramanujan sums) and hence "free".
**The harness refuted me** (2 of 9 moduli failed). Root cause: for `n ≡ 3 (mod 4)`,
`−1 ∉ S`, so the Cayley digraph is **not undirected** and its eigenvalues are
**complex**; my check took `np.real(FFT)` and silently discarded exactly the
information it should have detected. With full complex eigenvalues the exact
statement is:

> ### ★★ λ_k = ( c_n(k) + J(k,χ) ) / 2,  with |J(k,χ)| = √n exactly when gcd(k,n)=1, and J = 0 when gcd(k,n) > 1

where `c_n(k)` is the Ramanujan sum (**polylog-computable**) and `J(k,χ)` is a
**Jacobi sum** with

```
J(k,χ) = J_p(k·q̄) · J_q(k·p̄) ,     q̄ = q⁻¹ mod p,  p̄ = p⁻¹ mod q ,
```

which **requires `p` and `q`**. Verified to `≤ 2.6e−13` on 11 moduli
(`n = 15, 55, 91, 143, 187, 221, 323, 437, 667, 1155, 15015`).

**So the negative is stronger than the census's, not weaker.** The census said
*"the Ihara zeta needs the full spectrum, which needs the enumeration."* True,
but not the binding fact. The binding fact is that **the spectrum is itself
obstructed at every frequency**, not just at `λ_0`:

```
det(I − uA + u²D) = Π_k (1 − u·λ_k + u²·d),   d = deg
   k = 0  factor: 1 + d·u(u−1)                       ← needs d
   k ≠ 0  factor: 1 − u(c_n(k)+J(k,χ))/2 + u²·d       ← needs d AND J(k,χ)
```

There is **no frequency at which the zeta is free of the factorization**, hence
no `u` at which partial evaluation reveals anything.

**Scope damage the census did not record:** for `n ≡ 3 (mod 4)` the graph is
**directed** with complex eigenvalues, so the Ihara zeta — a formula for
undirected graphs — **does not apply at all**. That is **half of all RSA
moduli**.

---

## J3 — partial information. **VERDICT: no channel exists, by a one-line proof.**

`Σ_{x mod n} (x/n) = 0` **identically** (verified over every residue for
`n = 15, 45, 105, 231, 1155, 15015, 16785405`; all sums exactly 0). Hence
`deg = φ(n)/2` **exactly**: the count carries **no information beyond the
totient**, and the "extra channel" is provably empty, not merely small.

**The decisive fact (P11).** Since `g = |p−q| < S = p+q` always,

```
ε* = (2g−1)/(4(S+g−1))  <  2(S+g−1) / (4(S+g−1))  =  ½ .
```

Measured on 11 pairs spanning `g = 1` to `g = 4.09e6`: **every `ε* < ½`, max
observed 0.2500.** The degree is an **integer** and the tolerance is below ½, so
**the only admissible estimate is the exact value.** There is therefore *no*
partial-information channel — not `deg mod 2^k` for any `k`, not any estimate
with error ≥ ½ — and this needs **no sampling argument at all**.

For completeness, the low-`M` content (measured):

| n | deg | deg mod 2 | deg mod 4 |
|---|---|---|---|
| 15 | 4 | 0 | 0 |
| 91 | 36 | 0 | 0 |
| 253 | 110 | 0 | 2 |
| 10403 | 5100 | 0 | 0 |
| 1005973 | 501984 | 0 | 0 |
| 1000036000099 | 500017000032 | 0 | 0 |

`deg mod 2 = 0` **always** (deg is even for every odd semiprime) — free and
useless. `deg mod 4 = 2` iff `p ≡ q (mod 4)`, else 0: **one bit**, and computing
that bit requires knowing `p` and `q` — it is a statement *about* them, not a
route *to* them. This is the same single-bit content the census found for the
class number in `H_crossdiscipline` §4.2; it reappears here unchanged.

Knowing `φ(n) mod 2^k` for large `k` is essentially knowing `φ(n)`, since
`deg < n/2` and so `2^k > deg` pins `deg` outright. Confirmed, and subsumed.

---

## J4 — the verdict: **CLOSE THIS LEAD.**

Four independent reasons, any one sufficient:

1. **J1.** `k* > n²` universally. The estimator cannot even match enumeration.
   Not "hopeless for random primes" — hopeless for **all** primes.
2. **Fermat.** The only regime where closeness helps is Fermat's, and sampling
   loses there by 28–48 orders of magnitude. A strict rediscovery of a strictly
   worse algorithm.
3. **J2.** The count is `φ(n)/2` — a restatement — and, stronger than the
   census, the **entire spectrum** is obstructed at every frequency by Jacobi
   sums of magnitude `√n`. Plus: for `n ≡ 3 mod 4` the Ihara zeta does not apply
   at all.
4. **J3.** `ε* < ½` always, so only the exact degree works; and
   `Σ(x/n) = 0` identically, so there is no second channel for partial
   information to be partial about.

**What this round adds beyond the census:** a corrected and *verified* precision
bound (§0.1, 7.8e−6 agreement across 3 decades of `n`); two scope corrections
(squarefree, even `n`); the exact spectrum theorem with the Jacobi-sum
obstruction (J2), which turns the census's assertion into a stronger
proved negative; and the `ε* < ½` observation (J3), which retires the
partial-information channel without a single sample.

**What would reopen it:** nothing in the estimation direction. A polylog method
reading `φ(n)/2` off the adjacency matrix is still a factoring algorithm. The
only non-restatement route is polylog `φ(n)`, which is the classical barrier.

---

## Self-audit

**Self-test written first** (`self_test.py`, **18/18 as predicted**, including
four deliberate controls). It was able to return the null answer and did so:
`recover_factors_from_s` returns `None` on 7999/8000 perturbed `s`; the Jacobi
symbol returns `0`; `jacobi_free` *refuses* even `n` rather than inventing a
value.

**Validated in the regime of use.** `ellcard` was not used at all. Ground truth
for `deg` is a brute-force count over **all** residues (no exclusions — `x = 0`
and every non-coprime `x` included), cross-checked against a second,
algorithmically independent Jacobi (trial division + Euler's criterion, vs.
reciprocity): **0 mismatches over 628327 pairs**, exhaustive over all 37 moduli
`≤ 200001` plus 200000 sampled residues each on three large ones.

**Three bugs the harness caught in my own work**, all of the same family this
program has been burned by before:

| # | what went wrong | how it was caught |
|---|---|---|
| 1 | P6 predicted the spectrum is free; it is not | 2 of 9 moduli disagreed; root cause `np.real(FFT)` discarding complex eigenvalues on the `n ≡ 3 mod 4` directed case |
| 2 | bisection of the precision bound returned garbage at `n ~ 10¹²` | float `s_est` has absolute precision `~10⁻⁴`, coarser than the `ε` under test — the same class as `int(n**(1/3))`. Fixed by carrying the estimate in `Fraction` throughout |
| 3 | claimed the construction is undefined for even `n` | the explicit witness search returned `None`; the claim was false and is withdrawn (§0.3) |

**`dickman.py` was not used.** No smoothness arises anywhere in this attack; the
`ρ` in this note is the Bernoulli density `deg/n → ½` of the indicator, not the
Dickman function. Verified by AST that no file here imports anything from
`_shared/`. **No conclusion in this note rests on a `ρ(u)` value.**

**Not done, as instructed:** no commit, no GitHub issue, no paper.
**No literature was consulted** — every claim here is proved or measured in this
directory, so no citation could be fabricated. `WebSearch` was not used.

**Reproduction:** `cd factor-scratch/r49exp/jacobi && python3 self_test.py &&
python3 j_experiments.py` (≈ 6 min total).