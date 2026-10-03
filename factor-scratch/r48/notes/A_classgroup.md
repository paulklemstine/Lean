# R48-A: Class-Group Lottery as an ECM-Independent L[1/2] Mechanism

**Date:** 2026-10-03  **Round:** 48  **Axis:** A
**Verdict: REFUTED.** Not as a statistical near-miss — structurally, twice over.
The smoothness advantage is a scale artifact, and even if it were real the
mechanism cannot use it, because the class group modulo p is the trivial group.

---

## 1. The mechanism as proposed (E6D_IDEA_ECM.md)

Pick D ≡ 0,1 (mod 4) with large class number h(D). In Q(√D) the order of the
ideal class of a prime p over p divides h(D). If h(D) is B-smooth, a random walk
in the class group from [p] should return to 1 within a B-smooth number of
steps, and gcd of a coefficient against N then reveals p — the class-group
analogue of ECM's use of E(Z/p) ≅ Z/mZ.

The whole bet is the E6b/E6c/E7 measurement that class numbers are unusually
B-smooth: 0.720 vs 0.440 for EC at ~29 bits, and 0.400 vs 0.320 for the
p-linked D = −q family.

## 2. Self-test first (it earned its keep)

`exp/test_clforms.py` — **PASSED**. It caught **six** real bugs before any
result was used:

| # | Bug | Symptom |
|---|-----|---------|
| 1 | `reduce` recomputed D from the already-updated `b` | corrupted discriminant, garbage output |
| 2 | enumeration scanned only non-negative `b` | dropped half the class group (h(−23)=2 instead of 3) |
| 3 | no final `b ≥ 0` canonicalisation on ambiguous forms | principal came back as (1,−1,167), every inverse test failed |
| 4 | counted imprimitive forms for non-fundamental D | h(−2476)=20 instead of 15 |
| 5 | `random.Random(7)` re-seeded **per call** | all 400 "samples" were one integer; rate read 1.000 |
| 6 | `is_smooth` returned True once `q > B` without checking the cofactor | control read 1.000 for random 12-digit ints |

Bugs 5 and 6 are the anti-degeneracy self-test (T10) doing exactly its job —
the harness could not see a 0% or a 100% rate until they were fixed. Two
further harness bugs surfaced in `h0_control.py`: a "0% stream" built from
`[B+1, B+2, …]` (many of those *are* B-smooth; read 0.858) and then from
`[nextprime(B)+i]` (walks back through composites; also wrong). Only distinct
primes > B give a true 0%.

Composition is verified: f·f⁻¹ = principal for every reduced form of 26
discriminants; associativity on all 15³ = 3375 triples at D=−2476; PARI
`qfbcompraw` agrees with an independent Dirichlet composition; my class
numbers agree with `qfbclassno` on every discriminant tested.

## 3. STEP 0 — the twin control: THE ADVANTAGE IS A SCALE ARTIFACT

This is the headline. `exp/h0_control.py`.

**The matching bug.** My first version of the control compared k-bit EC
orders against class numbers of D with |D| ~ 2^k. But h(−q) ≈ √|D|/π, so a
2^k-sized discriminant yields only a **2^{k/2}-sized class number**. That
inflated the class arm by ~2 in log₂ and manufactured gaps of **+0.42 to
+0.72** — an apparent reproduction of E6c's 0.720 vs 0.440, out of nothing
but a half-bit offset. This is precisely the flaw E6b's own caveat warned
about ("sizes not matched"), reproduced in a new place.

**The fix:** match on the bit length of the **order itself**. To get a k-bit
class number, search D of ~2k bits (verified: h of 20 bits needs |D| of 42
bits, h of 24 bits needs |D| of 50 bits).

Matched control, n = 200–300 per cell, Wilson 95% intervals:

| order bits k | B | class h(D) | EC m=p+1−t | uniform | **gap class−EC** |
|---|---|---|---|---|---|
| 16 | 256 | 0.043 | 0.030 | — | **+0.013** |
| 16 | 40 | 0.043 | 0.030 | — | **+0.013** |
| 20 | 1024 | 0.263 | 0.300 | — | **−0.037** |
| 20 | 101 | 0.053 | 0.040 | — | **+0.013** |
| 24 | 4096 | 0.255 [0.200,0.320] | 0.305 [0.245,0.372] | 0.330 | **−0.050** |
| 24 | 256 | 0.045 [0.024,0.083] | 0.030 [0.014,0.064] | 0.040 | **+0.015** |
| 29 | 23170 | 0.300 [0.241,0.367] | 0.350 [0.287,0.418] | 0.295 | **−0.050** |
| 29 | 812 | 0.085 [0.054,0.132] | 0.085 [0.054,0.132] | 0.035 | **+0.000** |

Median order bit-lengths now agree across arms (verified k and k), so the
matching is genuine. **Gates:** the preregistered gate was "gap < 10 pp at
every matched cell ⇒ lottery advantage refuted." Every cell is ≤ 2 pp, and
**four of eight are negative**. The advantage does not merely shrink, it
reverses sign. Against the correct Hasse-constrained EC baseline
(m = p+1−t, |t| ≤ 2√p) class numbers are **not** smoother.

**Verdict on H0: REFUTED.** The 0.720-vs-0.440 and 0.400-vs-0.320 figures are
reproducible only under a half-bit scale mismatch. Both families are governed
by the same Dickman function at matched scale.

## 4. STEP 1–2 — the structural refutation (H1): p cannot constrain the walk

Even granting a smoothness advantage, the mechanism still fails, because
**the class group modulo p is trivial in every case**. `exp/h1_degenerate.py`.

- **p ∤ D:** O_D/p is a field F_{p²} (D a nonresidue) or F_p × F_p (D a
  residue). Both are semilocal, every ideal is principal, so Cl(O_D) → Cl(O_D/p)
  is trivial. The walk state carries **no mod-p information**; a gcd can fire
  only by coincidence at rate ~1/p per step.
- **p | D:** D ≡ 0 mod p, so writing t = b/(2a) every form satisfies
  c = a t² (mod p) — verified numerically for p = 101, 211, 307, 401, 503, 601.
  The ideal of [a,b,c] is (a, (b+√D)/2); mod p, √D = 0, so this is
  (a, b/2) = a·(1,t) = a·O_p — **always principal**. O_D/p ≅ F_p[e]/(e²) is
  local (ideals (1), (e), (0), all principal), so again the class group mod p
  is trivial.

My preregistered prediction here was **wrong in an informative way**. I
predicted the residue group would be (F_p,+) of order p. Measurement says
otherwise. The decisive test is **persistence**: if the residue map were a
group homomorphism and k were a genuine order, then returning to the principal
residue at step k would persist at step k+1. It does not:

| p | first-return time k | principal at k? | principal at k+1? | a real order? |
|---|---|---|---|---|
| 101 | 14 | True | **False** | No |
| 211 | 9 | True | **False** | No |
| 307 | 3 | True | **False** | No |
| 401 | 20 | True | **False** | No |
| 503 | 21 | True | **False** | No |
| 601 | 10 | True | **False** | No |

**6 of 6 primes: the return is non-persistent.** So "reduce the form mod p" is
not a group homomorphism, there is no order, and hence nothing whose
smoothness could be tested. The refutation is *stronger* than predicted — not
"order p, no lottery available" but "no group at all."

## 5. What the walk actually does (H2) — and why it is N^{1/4}, not L[1/2]

`exp/h2_walk.py`. The walk is given **only N and D**; p is used solely to
build instances and verify answers.

A reduced positive definite form obeys a ≤ √(|D|/3) (since |D| = 4ac − b² ≥ 3a²).
Consequences:

- **D = −N:** a ≤ √(N/3) ≈ p/√3 < p for balanced N = pq. The value a = p is
  **unreachable**, so gcd(a, N) can never fire. Verified: p > ⌊√(N/3)⌋ at
  12, 14, 16 bits.
- **D = −4N:** a ≤ √(4N/3) ≈ 1.155p > p, so a = p *is* reachable.

So the mechanism reduces to: **hit the single specified value a = p** among
~p reachable leading coefficients. That is a birthday problem, cost ~√p = N^{1/4}.
Measured confirmation — when a factor is found, a_k is *exactly* p:

| p bits | factors found | a_k == p | median steps |
|---|---|---|---|
| 12 | 7/12 | **7** | 1097 |
| 14 | 8/12 | **8** | 6757 |
| 16 | 4/12 | **4** | 3980 |

19 of 19 factors had a_k = p exactly. There is no smoothness lottery here at
all — the walk must hit one named integer, and the cost is the birthday bound.

My step counts are 25–150× larger than √p and the fitted exponent is not
clean (my walk uses a fixed seed set and is not an optimised birthday walk), so
**I do not claim a measured exponent**. The N^{1/4} cost is a structural
statement about hitting a named value, and it matches the known complexity of
Shanks's SQUOF, whose Wikipedia page states: "Shanks' method has time
complexity O(N^1/4)."

This is the axis's real content: the class-group walk **is** SQUOF. It is a
genuine factoring algorithm, it does factor (14 factors found in the first
sweep), and it is N^{1/4} — asymptotically **weaker** than ECM's
L[1/2, √2]. It is not a new mechanism and not an L[1/2] one.

## 6. Honest accounting

**Which quantities used p.**
- All of §4 (H1): uses p by construction — we must know p to impose D ≡ 0 mod p.
  Legitimate: it measures group *structure*, not cost.
- §5 (H2) factored output: the walk sees only N and D; p is used to build
  instances and verify factors. No timing path touches p.
- §3 (H0): class numbers and EC orders are generated from D and p
  independently; no factor of any N is involved.

**What I could not do.**
- k = 40 and k = 60 control cells did not finish: `qfbclassno` on ~80–120-bit
  discriminants is too slow for this budget. The conclusion rests on
  k = 16…29, where the matching is verified.
- No citation is offered for the SQUOF O(N^{1/4}) complexity beyond the
  Wikipedia algorithm page quoted above (fetched this session, which also
  contains two transcription errors — `T_{−1}` undefined, and `b_i` used where
  `b_j` is meant). I did not rely on it for any claim beyond that one
  complexity statement, and a direct transcription of that page's SQUOF fails
  (b = 0 on the first reverse step for every k on N = 11111), so I implemented
  the walk from the class-group formulation instead.
- WebSearch was not used for any citation.

## 7. Verdict

**REFUTED — CLEANLY, AND TWICE.**

1. **The lottery advantage is a scale artifact.** Matched on order bit-length,
   class numbers are no smoother than Hasse-constrained EC orders (gaps −0.05 to
   +0.02, four of eight cells negative). The E6b/E6c/E7 numbers need a ~half-bit
   offset to appear.
2. **Even a real advantage would be unusable.** Cl(O_D) mod p is trivial in both
   cases (p ∤ D: semilocal quotient; p | D: ideal is a·(1,t), principal). There
   is no group order whose smoothness could be tested.

And the prototype, once finished, factors — but by hitting a = p, a birthday
problem at N^{1/4}. That is SQUOF, known since Shanks, and strictly weaker than
ECM.

**The axis should be closed.** The single live positive lead of a 47-round
program is not live: its motivating measurement does not survive matching, and
its mechanism is blocked by a one-line fact about ideals in semilocal rings.
The prototype work is not wasted — the harness (self-tested to six bugs) and
the scale-matching protocol are reusable for any future smoothness-rate claim,
and the finding that E6b's caveat was load-bearing is worth propagating to any
other round that cites those numbers.

**Recommendation:** do not re-open. If a class-group-flavored factoring idea is
wanted later, the honest live question is not smoothness but whether any
construction gives a walk a group whose mod-p order is *random* (as E(F_p)'s
Hasse-bounded order is) — and the ideal-theoretic reason above says quadratic
orders cannot supply one.
