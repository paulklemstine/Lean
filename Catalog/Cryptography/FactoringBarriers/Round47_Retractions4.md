# Round 47 part 20 — FOUR of my own claims refuted, including the framing I repeated most

**2026-09-29. Agent A12. This retracts the "price of rigour" synthesis, the Chebotarev
reading, the 224-dex figure, and the claim that the ordinary NFS pays nothing. All four were
mine, all four were filed today, and all four are wrong.**

---

## 1. MY "STANDARD NFS RESOLVES THE SIGN RIGOROUSLY" — REFUTED

**The standard NFS's resolution is an explicit RETRY LOOP, and its termination is a
conjecture.** Bühler–Lenstra–Pomerance, p. 44, page image:

> "the number of times that we cycle through Steps 4 to 7 is one more than the number of
> times that we find a trivial factor of `n` in Step 7, **which is heuristically bounded by
> `(log n)^{O(1)} = y^{o(1)}`. Thus our assertion follows, heuristically**, from (11.8). …
> **it is reasonable to conjecture** that ultimately one of these relations will give rise to
> a non-trivial factor of `n` in Step 7."

Step 7 itself is the retry: *"If this is a non-trivial factor of n, Output the result and stop.
Otherwise, remove an element of S from T and start again at Step 4."* Confirmed in practice
by LLMP (*The Factorization of the Ninth Fermat Number*, Math. Comp. 61 (1993) 319–349,
p. 327): *"If the factorization is trivial (because `x = ±1`) … then one repeats the same
procedure starting from a different dependency."* Same page, p. 326: *"(In general, hardly
anything has been rigorously proved about practical factoring algorithms.)"*

HAC §3.2.5 p. 95: *"**with high probability** at least one will yield an `(x,y)` pair
satisfying `x ≢ ±y`"*; §3.12 p. 127: GNFS *"have heuristic (or conjectured) rather than proven
running times."* LV p. 2: *"**its analysis has been thus far entirely heuristic** … **in
implementations the NFS cannot assure the reduction**."*

**So there is no rigorous standard route either. The standard NFS and Lee–Venkatesan share
the same unproved step.**

## 2. MY "3/4" WAS AN ARITHMETIC SLIP — the truth is 0-or-1/2

For `n = pq`, `x ≡ y` **and** `x ≡ −y` are **both** trivial, so **2 of 4** sign patterns are
trivial: the non-trivial fraction is **exactly 1/2**, or 0. **`3/4` is the `ω(n) = 3` value.**

Measured exhaustively over all `(x,y) mod n` with `gcd(y,n)=1`: `n=15 → 0.500000`,
`n=77 → 0.500000`, but `n=30 → 0.750000`, `n=105 → 0.750000`. Then 400 random semiprimes ×
4 factor bases and 20 × 2 exhaustive kernel sweeps: **1/2 in 420/420**.

The non-trivial fraction is `1 − 1/[K:T]`, so for a semiprime it is **0 or exactly 1/2** —
not "3/4, many small chances".

## 3. THE ARGUMENT IS LEE–VENKATESAN'S OWN, AND CONDITIONAL ON CONJ 7.1

My counting argument is the **Proof of Theorem 2.3**, LV p. 39:

> "**since `χ_P` is not a product of these characters**, on the kernel … we must have that
> `χ_P` = −1 for a subspace of codimension 1 … we can guarantee that the relationship we
> find is fruitful **with probability 1/2**."

**The clause *"since `χ_P` is not a product of these characters"* IS Conjecture 7.1.** Remove
it and non-triviality is not shown at all. **So "LV buys nothing the standard approach does
not have" is exactly backwards: the standard approach and LV share this argument, and LV is
the one who wrote down the hypothesis it needs.**

And LV p. 39, Remark 7.3, answers the general case directly:

> "**The situation where `p, q` are not both `3 (mod 4)` is more complex, as there is no
> single character which can be used to consistently define which branch of the square root
> has been taken modulo `p` and `q`.** … so it is unclear how (even notionally) one might show
> that the linear algebraic step may produce non-trivial congruences."

**Where the sign pattern is forced by the field, the fraction collapses to 0** — exactly what
Conj 7.1 excludes and what BLP p. 44 conjectures against.

## 4. THE ORDINARY NFS **DOES** PAY A SIMILAR COST — BLP list four obstructions

`Round47_PriceOfRigour.md` Fact A said *"the ordinary NFS never pays this"*. **Refuted**, BLP
p. 15:

> (6.4) "Even if `∏(a+ba)O = γ²O` for some `γ ∈ O`, **it is not necessary that**
> `∏(a+ba) = γ²`." … "if `O` is a principal ideal domain and we have an explicit basis for
> the unit group … we can handle the obstruction (6.4) by linear algebra … **However, in
> general we cannot make any of these assumptions.**"

So between "the linear algebra produced a dependency" and "you have a congruence of squares",
the standard NFS pays the **class-group** and **unit** costs (6.3, 6.4), plus `Z[α] ≠ O`
(6.5) and irreducibles ≠ primes (6.2). It discharges them with the `χ_Q` characters.

**The dimensional-closure mechanism survives as a description of LV's formulation. Its
corollary about the ordinary NFS does not.**

## 5. THE `L[1/3]` IS **ALREADY PROVEN** — what needs Conj 7.1 is the factoring

**LV p. 5, page image:**

> "**Theorem 2.1.** For any `n`, the Randomised NFS runs in expected time
> `L_n(1/3, ∛(64/9)+o(1))`, and produces a pair `x, y` with `x² = y² mod n`."

**Unconditional, GNFS constant.** So the record's framing — *"the single remaining obstruction
to a proven `L[1/3]` factoring algorithm is Conjecture 7.1"* — **must be restated**:

> **The `L[1/3]` running time is proven. What needs Conjecture 7.1 is `x ≢ ±y`, i.e. that
> the congruence of squares is non-trivial, i.e. the factoring.**

Relations are abundant, not the constraint: LV p. 39, *"Running the Randomised NFS for at most
`L_n(1/3, 2σ+o(1))` time guarantees to find **every possible factor** `a − bX`"*, and Thm 2.6
needs only an `Ω(log log n)` factor more relations than Thm 2.5 supplies. **My "relation count
is not the constraint" — that half survives, and it survives against round 47's own emphasis.**

## 6. THE CHEBOTAREV REMARK IS A **DIFFERENT** OBSTRUCTION, AND IT IS **CLOSED**

`Round47_SUMMARY.md` §4 says the missing lemma is "Chebotarev-strength joint character
decorrelation … nobody has done since 2018". **Both halves are wrong.** The primary source
settles it — **BLP p. 27, their *own* conjecture**:

> "if they [`χ_Q`] do [span `Hom(V/K*², {±1})`] … **A rigorous proof of the conjecture along
> these lines would require a very strong effective version of the Cebotarev density theorem,
> which presently appears to be completely out of reach.**"

That is **square-detection / full rank** — the `χ_Q`-spanning step, i.e. obstructions 6.3–6.4.
**It is not the sign.** And it is **closed**: **LV Lemma 6.6 (p. 30) is unconditional**, and
**Remark 6.7 (p. 31)**: *"**We will in fact achieve this unconditionally** with
`c = 3/4 δ + o(1)` … **We observe that formal guarantees of this form are not present in the
literature.**"*

> **It was done in 2018, in the same paper, unconditionally, and the authors say so.**

## 7. THE 224-DEX FRAMING — RETRACTED, AND IT WAS ARITHMETICALLY WRONG

```
N^(1/5)                        = 10^123.30
L_N[1/3, 1.92299]  (LV Thm 2.1) = 10^35.19
dex gap                        = 88.12          at 2048 bits
```

Two errors, both mine:
- **"Rigour is paid in the L constant" is FALSE** — LV's *rigorous* constant `(64/9)^{1/3} =
  1.92299` is **identical** to the heuristic one. Rigour costs nothing in the constant.
- **"224.4 dex at 2048 bits" is arithmetically wrong.** The gap `N^{1/5}` vs
  `L[1/3,1.92299]` is **11.58 / 35.53 / 61.36 / 88.12 / 143.19 / 199.49** dex at
  512 / 1024 / 1536 / **2048** / 3072 / 4096 bits; **224.4 is reached at ≈4544 bits**. The
  224 figure compares `N^{1/5}` to **GNFS** — a different axis, saying nothing about Conj 7.1.

**"Paid twice" fails on both payments.**

## 8. A PHANTOM IN **MY OWN AGENT BRIEF** — the campaign's pattern, reproduced by me

I wrote into A12's brief: *"Lenstra's `Algorithms in algebraic number theory`, Compositio
Math. 56 (1988) 283–319"*. **Crossref: that paper does not exist.** The real record is
H. W. Lenstra Jr., *Algorithms in algebraic number theory*, **BAMS 26 (1992) 211–244**.

**Phantom #15, and I wrote it myself today, in a brief meant to prevent exactly this.**
It is the same failure the record has produced fifteen times, and I reproduced it while
lecturing an agent about citation discipline.

## 9. Status of everything round 47 claimed

| claim | status |
|---|---|
| relation geometry is genus 1 at `d=3`, genus 5 at `d=4` (generic) | **STANDS**, machine-checked |
| `N² ∣ disc(E)`, so the descent factors `N` | **STANDS**, machine-checked |
| "12/12 factors recovered" | **VOID** (unchanged) |
| GNFS constant `1.923` correct, derived, unmoved | **STANDS** |
| **"Conj 7.1 is the price of rigour, paid twice"** | **RETRACTED** — §4, §7 |
| **"the ordinary NFS never pays this"** | **RETRACTED** — §4 |
| **"the real missing lemma is Chebotarev decorrelation, open since 2018"** | **RETRACTED** — §6; it was a different obstruction and it is closed |
| **"224.4 dex at 2048 bits"** | **RETRACTED** — §7; it is 88.12, and it is a different axis |
| **"a proven `L[1/3]` is blocked by Conj 7.1"** | **RETRACTED** — §5; the `L[1/3]` is proven, the *factoring* is not |
| **"the relation count is the binding constraint"** | **RETRACTED** — §5; relations are abundant, the 1/2 being 0 is the constraint |
| **"the standard route resolves the sign rigorously"** | **REFUTED** — §1 |
| **"3/4 non-trivial"** | **REFUTED** — §2; exactly 1/2 |
| the function-field diagnosis (**rationality filter**) | **STANDS** — `Round47_FunctionField.md` |

**The 47-round target is unchanged**, and A12's own 420/420 measurement is *consistent with*
Conj 7.1 and therefore worth **nothing** toward it — as the agent says itself.
