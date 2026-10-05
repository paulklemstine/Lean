# Round 55 — the class-group closure is right for the wrong reason

**2026-10-05. NO new factoring algorithm, and NO reopening. But the closure's stated
REASONING is refuted and its other conjunct is FALSE.**

Paper: **`Papers/the_class_group_closure_is_right_for_the_wrong_reason.md`** (#540).
Code: `factor-scratch/r55exp/hnfdesc/`. All moduli `N < 2⁴⁶`, self-generated.

---

## 1. THE CLOSURE UNDER TEST

`Papers/fifty_two_rounds.md:173`: *"`h` B-smooth ∧ `p ∣ h` ⟹ `p ≤ B`, **inconsistent at
the relevant bound**"* — a **two-conjunct conditional**. **Both conjuncts were tested, and
they fail differently.**

## 2. FINDING 1 — the smoothness premise is UNNECESSARY

The explicit reduced-form descent for `D = −4N` (derived from the discriminant, **not
recalled**; validated **15/15** against brute force incl. ordering, **8/8** against PARI
`qfbclassno`) recovers a genuine factor on **24/24** instances:

| cell | instances | descent | Pollard `p−1` |
|---|---|---|---|
| `smooth-both` | 8 | **8/8** | 8/8 |
| `smooth-one` | 8 | **8/8** | 8/8 |
| **`rough-both`** | **8** | **8/8** | **0/8** |

**The descent works on exactly the instances where the smoothness method fails.**
⇒ **"h must be smooth" is refuted as an argument.**

## 3. ★★ FINDING 2 — the other conjunct is FALSE; the closure is VACUOUSLY true

| population | instances | `p ∣ h(−4N)` |
|---|---|---|
| balanced, 17–25 bits | 250 | **0/250** |
| unbalanced, 13–21 bits | 300 | **0/300** |

`LPF(h) > p` in **250/250** (median `LPF(h)/√p ≈ 1.9`). **Verified independently by me:
0/23.**

⇒ **A conditional whose antecedent essentially never occurs.** The closure is labelled
**"unconditionally"** but is **vacuously** true — the implication is never exercised on
anything.

## 4. ★ FINDING 3 — the ρ-disguise control (the load-bearing test)

**(A) Magnitude:** descent/rho ratio **46×–819×** — *more* work, where a disguise would
need ~10³× **cheaper**.
**(B) Discrimination:**
```
Spearman(descent_forms, h(−4N))   = +0.977   <- tracks the CLASS NUMBER
Spearman(descent_forms, sqrt(p))  = +0.230   <- barely tracks rho's predictor
```
**(C) Adversarial cells:** structural asymmetry built against the smoothness story.
**POS 4/4, NEG 3/3.**

## 5. FINDING 4 — the REAL reason is COST, and it is STRICTLY STRONGER

The descent traverses `Θ(1)` of the class group (`forms/h` = **0.906** @34 bits,
**0.768** @38 bits), so cost `Θ(h(D)) = Θ(√N)` — **worse than ρ's `N^{1/4}` by a factor
`N^{1/4}`**, and at 2048 bits `10^273×` GNFS. **The "descent in small steps" hope dies
concretely: the ambiguous form sits at `a ≈ min(p,q) ≈ √N` and you must enumerate up to
there.**

**⇒ The closure survives, on grounds that need NO smoothness assumption at all.**

## 6. ⚠️ ERRORS — two would have produced false results

1. **★ THE DETECTOR FIRED VACUOUSLY ON `a = 2`.** `2 ∣ 4N` *always* and `gcd(2,N) = 1`
   for odd `N`. Unguarded, the descent "succeeded" on **every** instance in 2 forms with
   `gcd = 1` — **a false PASS that would have been the entire result.**
2. **★ A SILENT `a_cap` MANUFACTURED A FAKE STRUCTURAL RESULT.** The ceiling produced an
   apparently beautiful "forms/h collapses 1.85 → 0.030 with size" trend — **exactly the
   crack I was hunting — which was my own parameter.** *The most convincing result of the
   round was an artefact.*
3. **Imprimitive forms inflated every result by exactly 2×** — caught only by the
   absolute-count check; **it sharpened** `ρₛ` **+0.915 → +0.977**.
4. **A 2-adic root solver silently dropped roots** (`[3,11]` vs `[3,5,11,13]`), 3/11
   validation failures; my analytic Hensel lift was wrong.
5. **`control.py` is not byte-reproducible** — its last column is `time.time()`. **Checked
   rather than assumed:** stripping it, **every substantive quantity is identical.**

## 7. ★ FOUR MORE PHANTOMS (19–22), in the very line I was asked to audit

The corpus citation *"Lenstra–Pomerance, Math. Comp. 62(206):865–874 (1994)"* is a
**three-way fusion** — that volume/issue/pages is a **Frey–Rück** paper; the real
Lenstra–Pomerance is **JAMS 1992**.

## 8. NOT SETTLED

`Θ(√N)` rests on **two measured sizes, not a proof** · the **index-calculus** version
(the only headroom axis, `L[1/2,1]`) was **not implemented** · PARI's ERH-conditionality
for Hafner–McCurley unresolved · **nothing here reopens the route.**
