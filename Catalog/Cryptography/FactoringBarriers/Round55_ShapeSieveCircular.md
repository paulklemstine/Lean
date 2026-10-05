# Round 55 — the shape-aware sieve is circular

**2026-10-05. NO new factoring algorithm. The corpus's "best-motivated untried idea" is
CLOSED — not for lack of trying, but because the shape parameter IS a factor.**

Paper: **`Papers/the_shape_aware_sieve_is_circular.md`** (#541).
Code: `factor-scratch/r55exp/shapesieve/` (seeded; 3 scripts re-run twice, byte-identical).
**No modulus of cryptographic interest was factored.** All `N < 2⁴⁰`, locally generated.

---

## 1. VERDICT

> **A shape-sensitive sieving primitive DOES exist and was measured** — `B`-smooth survival
> of `u² mod N` runs **7–14% higher** for prime-power shapes than generic `pq` (exact
> permutation **`p = 0.0004`**, negative control `p = 0.25`). **But the effect SHRINKS as `B`
> grows — 1.4156 → 1.2277 → 1.1404 at `B` = 60 → 256 → 1024 — and it is WORTHLESS:** the
> channel opens only when `minFac(N) ≤ B`, needing `N ≤ 2²⁵` even for the friendliest shape.
> **0 of 36 cost-model cells have it open.**

**An advantage that decays as the sieve gets stronger is not an advantage** — `B` IS the
sieve's quality parameter.

## 2. ★ WHY NOBODY HAS DONE THIS IN ~90 ROUNDS — it is CIRCULAR

The corpus nominates `n = a^k b` and calls the shape **"free to read off `n`"**.
**Measured: it IS free — because `a` is a factor of `n`.** `a` poly-time readable,
**200/200, and 40/40 for every `k = 2..6`.**

> **Reading the shape IS factoring.** The corpus notices the visibility at
> `Round51_ShapeGap.md:122-124` and treats it as a **benefit**. **It is the opposite: it is
> the reason the idea cannot pay.**

**All three channels closed:** (A) shape-dependent sieving function `g` — needs the shape,
i.e. rho's job or factoring itself; (B) shape shrinks the range — **a shortened range *IS*
Pollard rho**; the corpus half-concedes at `:129-133`; (C) factor-base eligibility — needs
`N ≤ 2²⁵`.

## 3. ★★ THE FLAGSHIP LEAN THEOREM IS A TAUTOLOGY

```lean
theorem sieve_cost_shape_blind {N M : ℕ} (h : N = M) :
    Nat.minFac N = Nat.minFac M := by rw [← h]
```

**Hypothesis `N = M`. Proof: `rw [← h]`.** It **never mentions a sieve, a cost, or a factor
base.** It says two equal moduli have equal smallest prime factor.

**I verified the file is otherwise clean** — compiles `EXIT=0`, **0 `sorry`**, axioms
`[propext, Classical.choice, Quot.sound]`. **The corpus's "0 `sorry`" claim is TRUE, and
that makes it worse: the lead was FORMALLY DECORATED, NEVER FORMALLY MOTIVATED.**

Same shape as round 53's `all([])` periodicity and round 54's `λ`-vs-`k` slip — but here
the vacuity is **in a theorem statement**, so every downstream argument inherits it.

## 4. The closure

> **Theorem.** A shape-sensitive range sieve requires `minFac(N) ≤ B`; its cost is then
> `≥ B`, while rho costs `O(√(minFac N)) ≤ O(√B) < B`. **So `A` is strictly dominated by
> rho on exactly the moduli where `A` is shape-aware.** ∎
>
> **The channel is open exactly where it is useless.**

**NOT proved:** this closes **range sieves** only. **ECM, `p−1`, class-group methods are all
shape-sensitive and all exist.** Not closed: non-range smoothness tests; an oracle for
smoothness of a structured integer; and **`L_n[1/2,c]` for `c<1`**, the 34-year-old gap,
still the highest-ceiling item.

## 5. Two literature corrections

**Mulder's venue is WRONG** — *Research in Number Theory* **11**(1) 2024, not *J. Number
Theory* 2025 (Crossref-verified). And **he never compares to rho on `a²b`, never bounds his
claim to `a^k b`** — the corpus overstates on both counts.

**But a real mechanism exists underneath:** `h(Q(√(a²b))) = h(Q(√b))` — verified exactly
**25/25** — the class number is **invariant** under the shape. **Its magnitude I could NOT
measure** (PARI `qfbclassno` costs `~2^(0.6·bits)`, measured); that experiment is
**underpowered and I claim nothing from it.**

## 6. ⚠️ Errors

1. **★ The first shape-sensitivity experiment was VACUOUS and printed a confident per-cell
   table.** With `M² < N`, `u² mod N = u²` identically and **`N` never entered** — all six
   families returned the identical `0.13105`. **Only the pre-registered positive control
   caught it.**
2. **A pre-registered threshold (`ratio ≥ 3`) that I invented, which mislabelled a REAL
   effect as a "vacuous detector"** — the control fires at **1.1074**. **The threshold was
   badly chosen; the detector was not vacuous.** Recorded because a threshold invented after
   seeing the data is not a prediction.

## 7. Most likely place this is wrong

**Bernstein's "Small factors and partial sieving" could not be found in five APIs. If it
exists it is the closest neighbour**, and partial sieving changes the `#candidates` term — a
channel this analysis treats as fixed by `log N`.
