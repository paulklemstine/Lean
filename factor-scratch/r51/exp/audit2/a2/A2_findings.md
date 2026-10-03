# A2 — adversarial audit of the class-group "structural exclusion" (#522 §2.2)

**Auditor:** A2 assignment. **Date:** 2026-10-03.
**Target:** `/home/raver1975/lean/Papers/the_smoothness_wall_is_a_subgroup_wall.md` §2.2
**Code:** this directory, `a1_algebra.py`, `a2_ecm.py`, `a2b_rate.py`, `a2c_smooth.py`,
`a2d_witness.py`, `a2e_cost.py`, `a2f_power.py`, `a2g_scale.py`, `a2h_repro.py`,
`a3_patched.py`, `witnesses.json`.
**Ground truth validated first:** `qfbclassno` vs a brute-force count of reduced primitive
forms on 20 discriminants — **20/20 agree** (`a2_ecm.py` header block; extended the
paper's own 10-discriminant self-test). No result below rests on an unvalidated library.

> **Note on repository state.** Commit `a066a4b5b` ("TWO FATAL corrections from adversarial
> audit of my own papers") already patched §2.2 after my first read. I audited **both** the
> original and the patched text, because the patch itself introduced new defects. Where they
> differ I say so.

---

## VERDICT IN ONE LINE

**The paper's headline conclusion — that the class-group route cannot yield an `L[1/2]`
factoring method — SURVIVES, and survives more strongly than the paper argues it.** But
**"structurally excluded" / "impossible" does not survive**, and it should be struck. The
defect is not the algebra; it is that §2.2 proves a conditional about *one cost model*
(`h ≈ (kN)^{1/2}`, BSGS optimal) and then reports it as an unconditional impossibility.

There are **4 MATERIAL** defects, **1 MINOR**, and **3 findings favourable to the paper**
that the audit literature has got backwards and should be recorded.

---

## FATAL-1 (carried over, still live): the equivalence chain is DIRECTIONALLY INVERTED

**Where:** §2.2, the displayed chain. Both the original and the patched version.

The chain is offered as an *explanation* of "even `k = 1` is too slow", i.e. of
`2√(L ln L) < L ⟺ 4 ln L < L`. But `4 ln L < L` does **not** mean `L < 8.6`. It means
`L > 8.6`.

```
# a1_algebra.py, STEP 2
f(L) = 4 ln L − L  ( > 0  iff  4 ln L > L )

  L=   2.0000  4lnL-L=  +0.7726   ->  k >= 1  (NOT excluded)
  L=   8.6000  4lnL-L=  +0.0070   ->  k >= 1  (NOT excluded)
  L=   9.0000  4lnL-L=  -0.2111   ->  EXCLUDED
  L= 709.7800  4lnL-L= -683.5202  ->  EXCLUDED   (n = 1024)

root of 4 ln L = L :  L = 8.613169   ->  e^L = 5503.66
```

So the correct statement is `4 ln L < L ⟺ L > 8.613 ⟺ N > 5504`, and the paper prints
`⟺ L < 8.6 ⟺ N < 5400`. **The paper's own headline conclusion ("excluded once `N > 5400`",
abstract line 23, §6 line 274) is correct; the chain printed as its justification says the
exact opposite.** A reader taking the chain at face value concludes the class group is
excluded for *small* `N` and allowed for large `N`.

This is not a cosmetic slip — the chain is the paper's only *displayed* algebra, and it is
the thing a reader checks.

---

## MATERIAL-1: the patched `ln k` numbers were not patched

**Where:** §2.2, post-patch, "gives `ln k = 4√(L ln L) − L`, which is negative …:
**−573** at n=1024, **−1217** at n=2048, **−2539** at n=4096."

Commit `a066a4b5b` changed the **coefficient** 2 → 4 but left the three **numeric values**
untouched. Those values are the output of the *old* 2√ formula:

```
# a3_patched.py, section A
    n       L=lnN   lnk with 2*sqrt   lnk with 4*sqrt   paper
  256     177.45            -116.82             -56.19
 1024     709.78            -573.26            -436.73   -573   *** WRONG ***
 2048    1419.57           -1216.55           -1013.54   -1217   *** WRONG ***
 4096    2839.13           -2538.63           -2238.14   -2539   *** WRONG ***
16384   11356.52          -10705.24          -10053.96
```

**All three numbers in the current paper are wrong for the formula it is attached to.**
(The pre-patch text was self-consistent: 2√ formula with 2√ numbers. The patch made it
inconsistent.)

Severity is MATERIAL, not FATAL, because the sign — which is the only thing the sentence
asserts — is correct either way. But it is a *published, currently-live* arithmetic error
in the section presented as "a proof, not a measurement".

---

## MATERIAL-2: `p | h(−kN)` is NOT rare-and-never-observed. It happens, routinely, and I have witnesses.

**Where:** §2.1, "Independently, `p | h(−kN)` was observed **0 times in 890 trials**", and
the census line "0/890 divisibility".

The paper treats 0/890 as one of the two legs of the exclusion. **It is a null.** Under the
random-integer model the paper itself proposes (`h ≈ √(kN)/π · L(1,χ)`, `h/p ≈ √k/π · L(1,χ)`),
the probability that a given `h` is divisible by `p` is `≈ 1/p`. The paper's cell was
`p ~ 2^33` with 640 trials:

```
# a2f_power.py, section (1)
  p ~ 2^33, 640 trials:   null P(p|h) ~ 1.16e-10
                           expected hits = 7.45e-08
  -> P(observe 0) = 0.999999925 under the null
```

**A test whose null predicts `7 × 10⁻⁸` hits cannot distinguish "impossible" from
"probability 1/p".** It has no power whatsoever. The paper reports it as corroboration of a
structural claim; it is a measurement that could not have come out otherwise.

### And the event is not rare at all — it is common at small `p`

```
# a2_ecm.py, section 2a: exhaustive sweep, p,q = 3 mod 4 primes < 1200,
# N = pq, D = -4kN, k = 1..2000
     trials = 198000      HITS = 2028
     first hit: p=3, q=7, k=7, h(-4kN) = 6 = 2*3
```

```
# a2d_witness.py -- EXPLICIT WITNESSES p | h(-4kN)
         p          q          k     h(-4kN)     h/p
        11         19         39          88        8
        23         31          7          92        4
        43         47        274        1032       24
        79        103        287        2528       32
       127        151        321        2032       16
       179        227        151        1432        8
```

and at genuinely larger `p` (`a2f_power.py` section 3, witnesses persisted to
`witnesses.json`):

```
         4733        1801       4706        75728       16
        59233       79579      15877      3553980       60
```

**Witnesses exist at `p = 59233` with `k = 15877`.** So `p | h(−kN)` is *arithmetically
possible*, *occurs*, and *is not exotic* — the rate tracks `1/p` with a mild suppression:

```
# a2d_witness.py, STRUCTURE: measured rate vs the 1/p null (k=1..400, 1600-2400 trials/cell)
     p        1/p   measured       n   ratio m*p   z vs null
    11   0.09091    0.06875    1600      0.756      -3.08
    19   0.05263    0.02833    2400      0.538      -5.33
    43   0.02326    0.00458    2400      0.197      -6.07
   101   0.00990    0.00375    2400      0.379      -3.04
   127   0.00787    0.00042    2400      0.053      -4.13
```

The rate is suppressed relative to `1/p` (z ≈ −3 to −6, consistently), which is a real
effect worth understanding — but it is **finite and nonzero**, decaying roughly like
`c/p`, not like "never". The paper's own §2.1 already concedes the magnitude half of this
("measured ratios cross 1 well before k = 10"); it then draws a universal conclusion from a
sample that had no power to detect the positives.

**Correct statement of this leg:** *"`p | h(−kN)` has rate ≲ c/p; at RSA scale
(`p ≈ 2^1024`) it cannot occur within any feasible number of `k`-trials, for the
uninteresting reason that `1/p` is astronomically small."* That is a real exclusion — but it
is a *resource* statement about the `k`-sweep, not an arithmetic impossibility.

---

## MATERIAL-3: the `0/890` count is not reproducible from the cited scripts, and does not add up

The paper's §2.1 gives two cells and a total:

```
# a1_algebra.py, STEP 5
  'N~2^66, 40 instances, 16 k-values'  ->  40*16 = 640
  'N~2^53, 30 instances, k<=5'        ->  30*5  = 150
  TOTAL = 640 + 150 = 790
  PAPER SAYS 890.   890 - 790 = 100   *** ARITHMETIC ERROR ***
```

The two cells as printed **sum to 790, not 890**. And the two cells do not correspond to
the two scripts in the notes:

```
# a2h_repro.py
r3_classgroup.py  q1_divisibility() DEFAULTS: n_trials=300, kmax=8  -> 2400 pairs,
                  p,q = randprime(10^25,10^26)  =>  N ~ 2^166   (paper says 2^66, 640)
r3_why_zero.py    p,q = randprime(10^9,10**10) =>  p ~ 2^30, N ~ 2^60-2^66  (matches 2^66)
                  but it runs 40 trials x 22 k-values = 880 pairs, k up to 1024
```

**The most likely provenance of "890" is `40 × 22 = 880` from `r3_why_zero.py`**, rounded
or mis-transcribed — but that script was run with **one** cell, not the two the paper
describes, and `r3_classgroup.py` at its recorded defaults targets `N ~ 2^166` with 2400
pairs. Neither script, at its recorded parameters, produces the two cells the paper reports.

Note that `r3_why_zero.py`'s own printed output *does* contain the structural content the
paper disputes. Running it here reproduces `h/p` medians crossing 1 at `k = 2`
(median 1.1090), exactly as §2.1 concedes. So the concession is faithful; only the count is
unsupported.

---

## MINOR-1: the paper never defines `L[1/α]`

```
# grep over the paper
$ grep -c "L\[1/2\] *=\|L\[1/3\] *=\|L\[1/alpha\]" Papers/the_smoothness_wall_is_a_subgroup_wall.md
0
```

The cost table's two columns are the load-bearing quantities of the entire argument, and the
paper never writes down what they are. Recovering them required reading
`factor-scratch/r48/exp/r3_costaccount.py`. The definitions there are
`L[1/2] = exp(½√(ln N ln ln N))` and `L[1/3] = exp(c(ln N)^{1/3}(ln ln N)^{2/3})` with
`c = (64/9)^{1/3} = 1.923`. Both reproduce the paper's table to the printed precision:

```
# a3_patched.py, section C
    n   L[1/2] c=0.5    paper   L[1/3] c=1.923    paper
  256          21.87    21.87             46.66    46.66   MATCH
 1024          49.24    49.24             86.77    86.77   MATCH
 4096         108.38   108.38            156.50   156.50   MATCH
16384         234.90   234.90            276.52   276.52   MATCH
```

---

## THE BIG QUESTION (axis 2) — IS BSGS REALLY THE RIGHT ALGORITHM?

**The paper assumes it. It is not, and the paper's own §3 says so — but the conclusion is
the same, because the real block is stronger.**

### The ECM analogy, run to completion

ECM beats `√p` because `#E(F_p)` is a *random* integer `m ≈ p` whose smoothness you can
test, and — crucially — **ECM does not need `p | m`.** It factors `p` because the curve
arithmetic *reduces mod p*, so a smooth order lets the walk collapse to a relation that
reads out `p` through `gcd`. The extraction is supplied by the group law, not by divisibility.

Porting that to the class group requires two things:
- **(S)** `h(−kN)` is `B`-smooth — testable, and `h` is computable (PARI `qfbclassno`), so
  one **can** sieve over `k`.
- **(D)** `p | h(−kN)` — the paper's leg 1.

I ran the sieve. **It works — and it is useless, for a reason that is arithmetic, not
statistical.**

```
# a2c_smooth.py, section 2c
  instance: p has 20 bits, B has 15 bits -> p > B: True
  k tried=3000  h B-smooth: 2021  p|h: 0
  instance: p has 26 bits, B has 18 bits -> p > B: True
  k tried=3000  h B-smooth: 1758  p|h: 0
  instance: p has 32 bits, B has 20 bits -> p > B: True
  k tried= 252  h B-smooth:  153  p|h: 0
```

**>2000 of 3000 values of `k` give a `B`-smooth `h` — the lottery is not merely reachable,
it is *easy*.** The smoothness half is a solved problem. It buys nothing, because:

> **(S) ∧ (D) ⟹ `p ≤ B`.**
> `B`-smooth means every prime factor of `h` is `≤ B`. `p | h` means `p` **is** a prime
> factor of `h`. Hence `p ≤ B`. ∎

With `B = L[1/2]` and `p ≈ √N`, the two requirements are **mutually exclusive at every
size anyone cares about** — not improbable, *inconsistent*. This is the strongest single
observation in this audit, and it is **strictly stronger than the paper's cost argument**:
it kills the ECM-style route without any appeal to `h ≈ (kN)^{1/2}`, without BSGS, and
without a smoothness estimate.

**And there is a second, independent kill** — the one `A_classgroup.md` §4 already
established and which the paper mentions only in passing: `Cl(O_D) → Cl(O_D/p)` is
**trivial** (semilocal quotient when `p ∤ D`; the ideal of `[a,b,c]` is `a·(1,t)`, always
principal, when `p | D`). **There is no mod-`p` homomorphism to reduce into**, so there is
no analogue of ECM's group-law readout. Even a perfectly smooth `h` cannot produce a
factor. This is a *structural* exclusion, in the paper's own intended sense — and it is a
different one from §2.2.

### Does the ECM-style sieve beat `N^{1/4}`? No — and it is self-defeating twice over.

```
# a2e_cost.py, cost section
      n   B=L[1/2] ln B   u=ln H/ln B   ln rho(u)   -ln rho
    256          15.157         5.854      -7.823      7.82
   1024          34.131        10.398     -22.797     22.80
   4096          75.124        18.896     -57.010     57.01
  16384         162.821        34.874    -133.192    133.19
```

The `−ln ρ` of the *search for a good `k`* is 7.8 / 22.8 / 57.0 / 133.2 in natural log,
against `ln L[1/2] = 15.2 / 34.1 / 75.1 / 162.8`. **Finding the `k` costs a constant
fraction of the entire `L[1/2]` budget — before any walking** — and then the walk must
still reach `p`, which §2.3 correctly identifies as SQUOF at `N^{1/4}`. So even granting the
lottery, the route loses.

### Does the class group ever break the `h ≈ (kN)^{1/2}` law badly enough to matter?

The paper flags this itself (§2.2 caveat, genus factors for `k > 1`, Heegner-type `D`).
Measured, the answer is **no, and the deviation is a constant**:

```
# a2c_smooth.py, section 2d: log2( h / sqrt(4kN/pi) ), k=1..60 x 6 instances
 p bits      k range       min       p05       med       max       n
     20     1..60 x6     -2.40     -1.63     -0.73      0.95     360
     26     1..60 x6     -2.07     -1.62     -0.69      0.70     360
```

Worst observed: `h` is `2^{-2.4} ≈ 1/5` of the law, i.e. `√h` is a factor `≈ 2.3` below
`N^{1/4}` — **about 1.2 bits**. And the classical extremes behave the same way:

```
# a2c_smooth.py, SMALL-CLASS-NUMBER EXTREMES
       D        h   sqrt(D/pi)    ratio   log2 sqrt(h)  log2 N^(1/4)
    -163        1         7.20   0.1388          0.00          1.84
    -427        2        11.66   0.1716          0.50          2.18
    -667        4        14.57   0.2745          1.00          2.35
```

Landau–Siegel guarantees `h(−D) = D^{1/2+o(1)}`; the worst case `h/sqrt(D/π) ≈ 0.14` is a
factor ≈ 7, i.e. **≈ 1.4 bits in `log₂√h`**. Against a gap of 206.76 bits (`n = 1024`) this
is **0.7 % of the margin**. The paper's caveat is warranted but harmless; the `h ≈ (kN)^{1/2}`
model is adequate to the conclusion.

---

## WORDING STRENGTH (axis 3): "impossible" is not justified

The paper says (abstract): *"This is not 'unlikely'; it is **impossible**"*; and §2.2:
*"structurally excluded, not merely unlikely — a categorically different status from every
other closure in this program's census."*

**This is over-strong, and the over-statement is load-bearing in the abstract.** The claim is
conditional on three assumptions, none of which is stated as a hypothesis:

1. **`h(−kN) ≈ (kN)^{1/2}`.** A heuristic. Measured deviation is ≤ 2.4 bits (above), and
   Landau–Siegel makes it sub-polynomial — fine, but it is an approximation, not an identity.
2. **BSGS is the right algorithm.** This is the one the audit was asked to attack, and it is
   *false as a general principle* (ECM is the counterexample, from the paper's own §3).
3. **`p | h` is required for the walk to reach `p`.** Now shown to be a **non-requirement**:
   it is one sufficient route, defeated arithmetically by `(S) ∧ (D) ⟹ p ≤ B`, and SQUOF
   reaches `a = p` by birthday collision without it.

What survives is a two-part conditional:

> **Conditional on** `h(−kN) ≍ (kN)^{1/2}` **and** on the class-group walk being SQUOF-class,
> the class group costs `(kN)^{1/4} > L[1/2]` for every `k ≥ 1` once `N > 1.8 × 10²⁹`
> (post-patch constant), so it yields no `L[1/2]` **through order-finding**. And
> independently, the smoothness route is killed by `p ≤ B`, and the mod-`p` readout by the
> triviality of `Cl(O_D/p)`.

That is a genuine closure and it is worth a paragraph. It is not "impossible", and calling it
"a categorically different status from every other closure in this program's census" is a
comparison the paper does not support — every other closure in that census is also a
cost-model conditional.

**Recommended edit:** replace abstract item 2's "This is not 'unlikely'; it is **impossible**"
with a statement of the two *unconditional* obstructions (`(S)∧(D) ⟹ p ≤ B`, and
`Cl(O_D/p)` trivial), demoting the `N^{1/4} > L[1/2]` comparison to "under the standard
`h ≍ √(kN)` estimate". The two unconditional obstructions are *stronger* than what is
currently printed, so this edit improves the paper.

---

## CONSISTENCY (axis 4)

`F_rigorous.md:418,419,427` and `A_classgroup.md` carry `0/890` / `640` / `150`.
- **The two source cells sum to 790, not 890** (MATERIAL-3).
- `A_classgroup.md` does **not** contain the 0/890 measurement — that is `F_rigorous.md`.
  `A_classgroup.md`'s own verdict is "REFUTED — cleanly, and twice over", and it cites
  `qfbclassno` verification, `0/640` in its `r3_why_zero.py` docstring.
- The paper cites neither the reproducing parameters nor a command, so a reader cannot
  re-run the 890. It should carry the script path, the RNG seed, and the exact `k` set.

---

## FINDINGS FAVOURABLE TO THE PAPER (recorded because the round's own audit got them wrong)

Commit `a066a4b5b` asserts two things about §2.2 that are **false**. I checked both.

### F1: "Both `L`-columns of the §2.2 cost table were wrong" — FALSE. The table is correct.

```
# a3_patched.py, section C — every cell reproduces to the printed precision
256/1024/4096/16384 : 21.87 / 49.24 / 108.38 / 234.90   and   46.66 / 86.77 / 156.50 / 276.52
```

Reproduced exactly from `r3_costaccount.py`'s definitions. The commit did not edit the table,
correctly — but its commit message states a falsehood about the paper, and §0.1 of the
current paper repeats it ("**Both `L`-columns of the §2.2 cost table were wrong**").

### F2: "`L[1/3] > L[1/2]` … an inequality that is never true" — FALSE.

```
# a3_patched.py, section D
    n     L[1/2]     L[1/3]   L1/3 > L1/2?
  256      21.87      46.66           True
 1024      49.24      86.77           True
 4096     108.38     156.50           True
16384     234.90     276.52           True
 65536     503.47     481.38          False
262144    1070.04     828.66          False
```

`L[1/3] < L[1/2]` is an **asymptotic** statement. At every size in the paper's own table the
reverse holds, and the crossover is around `n ≈ 40000` bits. The printed table is right.

### F3: the exclusion is ROBUST to the choice of `L[1/2]` constant — the paper is conservative.

The paper's `L[1/2]` uses constant `½`. True ECM is `L[1/2,√2] = exp(√2·√(L ln L))`, i.e.
constant `√2 ≈ 1.414` — a *harder* target. Using the true ECM constant:

```
# a3_patched.py, section E
    n   ln k, c=sqrt2      threshold           N*
 1024         -323.63        163.000    6.166e+70
 2048         -845.36        163.000    6.166e+70
 4096        -1989.20        163.000    6.166e+70
```

Still excluded, by a *wider* margin. Shoup's rigorous `2√2` is wider still. **The paper
understates its own exclusion by using a weak `L[1/2]`.** It should state which constant it
uses (see MINOR-1) and can then legitimately say the conclusion holds a fortiori against
heuristic ECM and against Shoup's proven bound.

---

## SEVERITY SUMMARY

| # | Severity | Defect | Evidence |
|---|---|---|---|
| FATAL-1 | **FATAL** | Equivalence chain directionally inverted (`4 ln L < L ⟺ L < 8.6` is backwards; second time, survives the patch) | `a1_algebra.py` STEP 2 |
| MAT-1 | MATERIAL | Post-patch `ln k` values (−573/−1217/−2539) are the *old* formula's; correct 4√ values are −436.73/−1013.54/−2238.14 | `a3_patched.py` A |
| MAT-2 | MATERIAL | `p \| h(−kN)` is **not** never-observed: 2028 hits/198000 trials, witnesses to `p = 59233`, `k = 15877`; and the 0/890 cell has null power 7.5e-8 | `a2_ecm.py` 2a, `a2d_witness.py`, `a2f_power.py` |
| MAT-3 | MATERIAL | `0/890` unreproducible: the two printed cells sum to 790; neither cited script at its recorded defaults produces them | `a1_algebra.py` STEP 5, `a2h_repro.py` |
| MAT-4 | MATERIAL | "Impossible / structurally excluded" is conditional on `h ≈ √(kN)`, BSGS optimality, and `p \| h` — none stated as hypotheses | axis-3 analysis |
| MIN-1 | MINOR | `L[1/α]` never defined in the paper; table is unreproducible from the paper alone | `grep -c` = 0 |
| F1 | *(favours paper)* | Prior audit's "both L-columns wrong" is **false** — table reproduces exactly | `a3_patched.py` C |
| F2 | *(favours paper)* | Prior audit's "`L[1/3] > L[1/2]` never true" is **false** — true at all four table sizes | `a3_patched.py` D |
| F3 | *(favours paper)* | Exclusion strengthens under true ECM constant √2 and Shoup's 2√2; paper understates itself | `a3_patched.py` E |

## THE STRONGEST DEFENCE OF THE CLAIM (which the paper does not currently make)

> For the class group to yield `p` via a smooth order, you need `h(−kN)` `B`-smooth **and**
> `p | h(−kN)`. Together these force `p ≤ B`, so at `B = L[1/2]` and `p ≈ √N` they are
> **mutually exclusive** — not improbable, inconsistent. Independently,
> `Cl(O_D) → Cl(O_D/p)` is trivial, so no mod-`p` readout exists even when both hold.
>
> This is **unconditional**, needs no smoothness estimate and no `h ≈ √(kN)` model, and is
> a strictly stronger exclusion than the `N^{1/4} > L[1/2}` cost comparison the paper leads
> with. It is the claim §2.2 should be making.

## WHAT SURVIVES

The class group is not a route to an unconditional `L[1/2]`. That is correct, and the two
unconditional obstructions above support it more robustly than the paper's current
reasoning. What does not survive is the framing: `p | h` is possible (not impossible), the
`0/890` cell carried no information, the printed chain says the opposite of the prose, and
the `ln k` values do not match the formula they are attached to.