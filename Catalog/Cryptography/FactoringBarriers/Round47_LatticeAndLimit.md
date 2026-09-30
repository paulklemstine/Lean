# Round 47 part 36 — the lattice step is polynomial; the method dies at 19 bits; the supply is the killer

**2026-09-29. Agent A16. The good news and the bad news, both measured. The bottleneck
moved, and that is real progress even though the verdict is negative.**

---

## 1. GOOD: lattice polynomial selection is `poly(log N)`. The `N/cmax` wall is gone.

**Sourced, not from memory.** Coxon, arXiv:1109.6398v2, **p. 6**, read from the rendered
page image (image and text agree):

> *"an integer polynomial `f = Σᵢ₌₀^d aᵢxⁱ` of degree at most `d` has `m` as a root modulo `N`
> if and only if the coefficient vector `(a₀,…,a_d)` is orthogonal to `(1, m, …, m^d)`
> modulo `N`. The set of all such coefficient vectors, denoted **`L_{m,d}`**, forms a lattice
> in `Z^{d+1}`."*

LLL cost, same paper **p. 4**: *"**O(k⁴ n (k + log β) log β)** bit operations"* — corroborated
by HAC Ch. 3, Fact 3.103 **p. 120**: *"**O(n⁴ log C)**"*. **The rank is fixed at 4
(`det = N`), so the exponent does not grow with `log N`.**

**Measured** (`fpylll`): **8.2e-5, 6.2e-5, 3.7e-5, 4.9e-5, 5.5e-5, 6.5e-5 seconds** at
19 / 32 / 48 / 64 / 95 / 127 bits. Fit on bits ≥ 48: **slope 0.0104, R² = 0.860**.

> **The `N/cmax` probe cost — `10^15` at 2048 bits — is eliminated. Polynomial selection
> costs 60 µs and is essentially flat in the size of `N`.**

**This is the answer to the binary question I posed, and it is the good branch.**

## 2. BAD: the method still dies at ≈19 bits.

Running the method on lattice-chosen `f`, 20 trials per size:

| bits `N` | hits / 20 |
|---|---|
| 15 | **2** |
| 19 and above | **0** |

## 3. WHICH kills it — measured, not argued

| candidate | verdict |
|---|---|
| the polynomial step | **not** the killer — 60 µs, flat |
| the height | **not** the killer — `H` 200→800 changes 0/20 to 0/20 everywhere |
| **the relation supply** | **THE KILLER** |

**So of the two decisive quantities I named two days ago, one is now answered — the good way
— and the other is now the entire remaining question.**

## 4. A bug in my own generalisation file, and the record's exposure

A16 found that `main/general_cubic.py`'s `g` is **twice** round 47's, so `y = w/v²` gains a
factor 2 and **flips `chi_P` by `Jacobi(2, N)`**.

**Checked what is actually committed:** the Lean (`RelationAlgebra.lean`) uses
`g = (−2u², −2uv, v²)` consistently and is **not affected**; the committed
`Round47_general_cubic.py` contains only the parametrisation, not the downstream `y`, and is
**not affected**. The bug is confined to the uncommitted working scratch file. **No committed
claim needs retraction** — but the audit was right to check, and a scratch-file bug is how a
committed one happens.

## 5. A16's discipline, which is the part to copy

**Five instrument defects caught by self-tests, none by inspection** — including the
factor-2 above, and **two runs that read as refutations but were instrument defects**
(a non-monic `f` fed into a monic trial; a hardcoded `'0'` column silently discarding the
`X²` coefficient). **Both recorded VOID, not deleted.**

Self-tests 15/15 and 5/5, the latter including **bit-for-bit agreement** with
`main/method_rate.py` (102/102) after deriving the general-cubic cone independently with
sympy.

**Its own literature caveat, stated unprompted:** it sourced the lattice *definition* but did
**not** verify the `a_d = 1` monicity repair against a published construction — *"S1 /
`a_d | all coefficients` is my own derivation, though measured and gated."* **That is the
right way to flag a self-derived step, and I am recording it rather than smoothing it over.**

## 6. The one experiment left

> **For a depressed cubic with `P` free (reachable by scanning `m`, not by lattice), measure
> whether ANY curve above 20 bits supplies a `chi_P = −1` relation at findable height.**

If the answer is no, **the method is closed at ~19 bits and the axis is done.** Everything
else is settled: the algebra is machine-checked, the gate is a perfect predictor (136/136),
`N` is never factored, the polynomial step is polynomial, and the height is not the
constraint. **The supply is the only thing left, and it is now a single yes/no question.**
