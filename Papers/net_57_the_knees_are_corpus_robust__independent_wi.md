# Computational evidence — NET-57 corpus algebra of the attention knee

All numbers below were produced by exact **rational** arithmetic inside Lean
(`#eval` over `ℚ`, no floating point), using the same definitions that the
formal development uses:

```lean
def hm (w : ℕ → ℚ) (k : ℕ) : ℚ := ∑ i ∈ Finset.range k, w i
def kneeQ (w : ℕ → ℚ) (n : ℕ) (t : ℚ) : ℕ :=
  ((List.range (n+1)).find? (fun k => decide (t * hm w n ≤ hm w k))).getD (n+1)
```

Test corpora (sorted attention profiles), gate `τ = 0.98` unless stated:

| name | profile | intended regime |
|---|---|---|
| `A` | `w i = (3/4)^i` | geometric decay (spectral gap) |
| `B` | `w i = (3/4)^i · (1 ± 10⁻⁴)` alternating | corpus-B analogue: four-decimal perturbation of `A` |
| `C` | `w i = 1/(i+1)²` | heavy tail |
| `U` | `w i = 1` | uniform (no gap) |

## 1. Knee ladders across context length

| corpus | ctx 8 | ctx 16 | ctx 32 | ctx 64 |
|---|---|---|---|---|
| `A` (geometric) | 8 | 13 | **14** | **14** |
| `B` (`A` ± 10⁻⁴) | 8 | 13 | **14** | **14** |
| `C` (heavy tail) | 7 | 11 | 16 | 21 |
| `U` (uniform) | 8 | 16 | 32 | 63 |

Two things are visible and both are theorems in
`Catalog/Algebra/NET57CorpusRobustKnee.lean`:

* every ladder is **non-decreasing in the context length** (`knee_mono_context`),
  so a measured ladder such as `{16, 32}` can never be inverted by a corpus;
* the four-decimal perturbation `B` reproduces the `A` ladder **entry for entry**
  — the empirical shape of NET-57's "controls replicate to four decimals ⇒ the
  knees replicate exactly", proved in general as `knee_eq_of_uniform_close`.

## 2. Pooling corpora (ctx 32, gate 0.98)

| pool | `k*` left | `k*` right | `k*` pooled | matches |
|---|---|---|---|---|
| `A + B` | 14 | 14 | **14** | `knee_add_eq` (equal knees are preserved) |
| `A + C` | 14 | 16 | **14** | `min` endpoint of the sandwich |
| `A + U` | 14 | 32 | **32** | `max` endpoint of the sandwich |
| `7·A`   | 14 | — | **14** | `knee_smul` (scale invariance) |

So the sandwich `min ≤ k*(A+B) ≤ max` is attained on *both* sides by natural
profiles, not only by the two one-hot witnesses used in
`sharp_knee_add_eq_min` / `sharp_knee_add_eq_max`.  In particular the knee is
**not additive** and not a function of the summand knees — hence the diagonal
hypothesis in `knee_add_eq` is necessary.

## 3. Gate sweep (corpus `A`, ctx 64)

`τ = 0.90 … 0.99` gives

```
k*(τ) = [9, 9, 9, 10, 10, 11, 12, 13, 14, 17]
```

monotone non-decreasing in `τ`, with plateaux — the step-function/quantile shape
formalised in `Catalog/Algebra/NET57KneeGateDuality.lean`
(`knee_mono_gate`, `retained_eq_sSup_gates`).

## 4. Gate margins near the knee (corpus `A`, ctx 64)

Retained mass ×10⁴ (truncated):

| k | 8 | 9 | 10 | 11 | 12 | 13 |
|---|---|---|---|---|---|---|
| retained ×10⁴ | 8998 | 9249 | 9436 | 9577 | 9683 | 9762 |

The smallest distance from the gate `0.98` over this window is `≈ 0.0038`, i.e.
**38× the 10⁻⁴ control tolerance**.  This is exactly the numerical situation in
which `knee_eq_of_uniform_close` applies, and it is why the four-decimal
agreement is decisive rather than suggestive.

## 5. Counterexample hunt

The universal claim tested was "pooling preserves the knee".  It **fails**: the
`A + U` row above raises the knee from 14 to 32.  The claim survives only on the
diagonal (equal knees), which is precisely the form proved.  A second hunt
targeted the margin hypothesis of the four-decimal theorem: the uniform corpus
sitting exactly on the gate (`retained = τ` at the knee) can be flipped by an
arbitrarily small perturbation, formalised as
`four_decimal_margin_necessary` — so the margin cannot be dropped.

No OEIS sequence is involved: the objects are real-valued retention curves, not
integer sequences.
