# Round 97 — frontier verification and new prior art (no method)

**2026-10-04. NO new factoring algorithm and NO exponent improvement.** This round
is a *verification and census* pass: two parallel literature sweeps (quantum;
special-form/partial-info) plus a targeted search on the one gap the repo itself
flags as open, plus a hand-check of a genuinely new mechanism paper. The net
result: the classical frontier is confirmed closed, three 2025 papers the repo
does not yet carry are recorded, and exactly **one named complexity question**
remains open.

---

## 1. Frontier, re-verified (unchanged)

| setting | bound | status |
|---|---|---|
| quantum | `poly(log N)` (Shor) | unbeaten; 2024–26 gains are depth/space only |
| classical, heuristic | `L[1/3,(64/9)^{1/3}]` (GNFS) | unbeaten |
| classical, deterministic | `O(N^{1/5}log^{16/5}N/(log log N)^{3/5})` (Harvey–Hittmeir, arXiv:2105.11105 / Math. Comp. 91 (2022)) | unbeaten |
| ECM | `L[1/2,√2]` | unbeaten |
| deterministic, conditional | `N^{1/6}` (Umans–Wang, conditional; AP variant **refuted** by He–Sahai arXiv:2608.06681) | higher-rank variant open |

Nothing in 2024–2026 beats any of these exponents. Quantum work since Gidney–Ekerå
is engineering (Gidney 2025: RSA-2048 in <10⁶ qubits, <1 week, *analytical*);
Regev's family improves *space* (arXiv:2511.18198: `O(n log n)`, claimed
lower-bound-sharp) but is asymptotically worse in total gates, and Ekerå–Gärtner
(arXiv:2405.14381) confirm it "does not achieve an advantage."

## 2. Three papers the repo does not yet carry

1. **Pomykała & Jurkiewicz, arXiv:2503.00950 (2 Mar 2025)** — "Decomposition of
   RSA modulus applying even order elliptic curves." A **new mechanism**: on the
   `E₂` family of even-order CM curves, 2-adic order separation (`l_min(E,Q)≤2`)
   plus a **deterministic finish** (write `N` in base `d = max ord`) decomposes
   `N` in `t^{1+o(1)}`. *Hand-checked:* the claimed separation does occur —
   ~80% of matched supersingular (`y²=x³−x`, `p≡3 mod 4`) curve pairs have
   `v₂(#E_p) ≠ v₂(#E_q)`, consistent with the mechanism. **But the bound is
   conjectural `L[√2+o(1)] ≈ 1.41`, which is *worse* than ECM's `1/2` and GNFS's
   `1/3`.** This is a genuinely novel route, **not a better bound.**
2. **Gao, Feng, Hu, Pan, arXiv:2512.19076 (Dec 2025)** — a **rank-3 Coppersmith**
   lattice using the *second* LLL vector (dodging BSGS trivial collisions).
   Rigorous; improves the **log-log factor** of deterministic `N^{1/5}`
   (`log^{13/5}` vs `log^{16/5}`), and gives faster `r`-th-power-divisor finding.
   The **exponent `1/5` is unchanged.**
3. **Hittmeir, arXiv:2205.10074** — Fermat/small-difference factoring via a
   multiple-choice subset-sum sieve; a large subexponential-factor speedup, still
   in the `N^{1/5}` deterministic class.

## 3. The ONE open complexity question (and its exact boundary)

The repo's `RESEARCH.md` (#499) already flags it; both sweeps confirm and sharpen it.

> **Open:** can `N=pq` be factored in polynomial time given **fewer than `n/4`
> known bits of `p`** (`n = log₂ N`) by any method — inside *or* outside the
> standard Howgrave-Graham/Coppersmith lattice family?

**What is closed.** Chinburg–Hemenway–Heninger–Scherr (ASIACRYPT 2016,
ePrint 2016/869) proved Coppersmith's univariate `N^{β²/d}` bound optimal **within
the univariate auxiliary-polynomial class** `h = Σ a_{ij} x^i (f/N)^j`, degree-free
and lattice-free, so no auxiliary polynomial of *any* degree reaches
`N^{1/d+ε}`. Aono–Agrawal–Satoh–Watanabe (ePrint 2012/108) had already shown
asymptotic tightness for the lattice family (heuristic). Together these make the
**`n/4` known-bits-of-`p`** barrier a technique ceiling.

**What is NOT closed — the precise gap.** CHHS explicitly limit their theorem to
the *univariate* auxiliary-polynomial form and list the **multivariate /
bivariate-integer** Coppersmith settings as future work. Extending capacity-theory
lower bounds to the multivariate RSA setting — i.e. ruling out (or achieving)
sub-`N^{1/4}` recovery with a jointly-chosen shift-polynomial system — is open.
Whether the *bivariate-integer* method behind Coppersmith's `n/4` (1996) admits a
sharper auxiliary-polynomial freedom than the univariate reduction is precisely
unresolved. **This is the single live complexity question in classical factoring.**

Non-lattice partial-info results (Heninger–Shacham 27% scattered *key* bits;
Jimenez Urroz ePrint 2026/1295 extended-Wiener on `d`) do **not** beat `n/4` for
bits of `p`.

## 4. Honest scope

* **No new factoring algorithm. No complexity beaten.**
* The record's own census gains three 2025 papers (§2) and a precisely-scoped
  statement of the one open question (§3), with the optimality boundary located
  on the **univariate/multivariate** divide — the sharpest available statement of
  where the `n/4` barrier is and is not proven.
* Round 96's conclusion is unchanged and now sits on a wider base: the
  deterministic `N^{1/5}` line is closed (UMW AP variant refuted; five GAP-cover
  walls); the heuristic `L[1/3]` line is untouched by any recent mechanism.

**The honest frontier for a *new* factoring method is therefore:** there is no
known asymptotic opening in any classical model, and the one *theoretically* live
sub-`N^{1/4}` question needs a multivariate capacity-theory result that has not
been written in 10 years. A new method would most plausibly come from the
multivariate-Coppersmith gap, from Pomykała–Jurkiewicz's even-order-curve
mechanism (a better finish would be needed to matter), or from a genuinely new
covering idea the five round-96 walls did not exclude.