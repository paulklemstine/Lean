# RESULT — verification axis BLOCKED: the shared-bias model, and a control that caught me

Round 118, `r118/bias-model/`.
**Status: BLOCKED. No measurement is publishable, and the reason is documented.** This entry
exists because the positive control caught a broken harness, which is the only thing that
distinguishes a null from an artefact.

## 1. What was being tested

The published nonce-leakage thresholds (Breitner–Heninger ePrint 2019/023, "a bias of just
4 bits"; LadderLeak's 1 bit/signature) are about a **shared unknown bias**: the nonces all
carry the same value in their top `ℓ` bits, and the attacker does *not* know that value.
Round 15 measured the **known-bits** model (`t·ℓ* ≈ 1.03–1.25 × log₂ n`). Same-currency
question: does the unknown-bias model need the same leakage, or more?

Unknowns `(a, K_1..K_t, d)`, `a < 2^ℓ`, `K_i < 2^{n−ℓ}`, `d < 2^n`:

```
s_i·(a·2^m + K_i) − r_i·d = z_i   (mod n),   m = n − ℓ
```

Counting bound: `2^ℓ · 2^{tm} · 2^n / n^t < 1 ⟺ ℓ(t−1) > n`, i.e. `t·ℓ ≈ n + ℓ` — the same
ballpark as known bits, so the two models *should* be comparable.

## 2. What was measured, and why it is not a result

Both models returned **0/8 at every cell**, including `t·ℓ/n = 1.03–1.125` where the
verified round-15 attack recovers the key. That already looked wrong, and the mandatory
control confirmed it: **the same construction with the bias value handed to the attacker —
which is exactly the round-15 known-bits model — also returned 0/8.**

Per the campaign's rule ("a harness that has never been shown to fire has measured
nothing"), the measurement is void. A control that does not fire means the harness cannot
represent the answer; it says nothing about the phenomenon.

## 3. Diagnosis (the construction is unbalanced)

Three defects, all visible in hindsight:

1. **`d` was never eliminated.** The verified round-15 construction differencing-kills the
   key coordinate before building the lattice (the structured-nonce worker's LCG attack does
   the same with its `h_i` differencing). Keeping `d` in the lattice leaves an unknown whose
   bound is the full `2^n`, which dominates the target vector's norm and makes it unfindable.
2. **No column scaling.** The unknown coordinates have wildly different bounds
   (`a < 2^ℓ` vs `K_i < 2^{n−ℓ}`), and no scaling was applied. Round 17 established that the
   column scaling is *structurally required* — `σ ≤ 32` never works at any `β`. The same
   lesson applies here.
3. **A first-harvest version reduced only the kernel**, not the affine lattice, so the
   solution was not in the lattice being searched. Fixed in v2 (particular solution
   `a = 0, d = 0, K_i = z_i/s_i` + Kannan embedding) — but the two scale defects above
   remain.

## 4. The fix, precisely specified (for whoever picks this up)

1. Eliminate `d` by **`r`-differencing**: for a reference index, multiply equation `i` by
   `r_j` and equation `j` by `r_i`, subtract — the `d` terms cancel exactly.
2. Apply **per-column scaling** so all target coordinates are comparable:
   `a ← a·2^{m−ℓ}`, `K_i ← K_i·2^ℓ` (each unknown scaled to `≈ 2^n`).
3. Kannan-embed the kernel with the particular-solution target row (this part already works).
4. **Re-run the positive control first** — the known-bias instance must reproduce the
   round-15 threshold curve — and only then measure the unknown-bias model.

## 5. What this does not tell us

Nothing about the shared-bias model itself. The published claims remain **unverified in this
campaign's harness**, which is a real gap: they are the basis of the "4 bits suffices"
numbers quoted in the round-15 brief's literature table. Until the harness above is fixed
and the control fires, this campaign has no measured position on the most-cited published
threshold claim.

## 6. Traps (fourth instance of one pattern in this session)

Each of round 15's harvest bug, the LCG `a^i` formulation, the `(-M) % M` slack deletion, and
this one produced a *confident null* from a construction that could not represent the
answer. The mitigation is now routine and worked again here: **the positive control is not
optional, and a threshold claim in particular must be checked against a point where a
verified attack is known to succeed before the comparison means anything.**
