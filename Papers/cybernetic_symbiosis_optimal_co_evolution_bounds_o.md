# Computational Evidence — Cybernetic-Symbiosis co-adaptation loop

## Model

Human signal `h` and decoder output `d` mutually adapt with gains `a`, `b`:

```
h(n+1) = (1-a) h(n) + a d(n)
d(n+1) = (1-b) d(n) + b h(n)
```

Define the disagreement `e(n) = h(n) - d(n)`. Algebra gives the exact scalar recursion

```
e(n+1) = (1 - a - b) e(n)   =>   e(n) = q^n e(0),   q := 1 - a - b.
```

So the whole convergence question reduces to the single contraction factor `q`.

## Small-case calculations (start (h0,d0) = (1,0), so e0 = 1)

| gains (a,b) | q = 1-a-b | e0,e1,e2,e3,e4 | behaviour |
|-------------|-----------|----------------|-----------|
| (0.2, 0.3)  | 0.5       | 1, .5, .25, .125, .0625 | geometric decay to agreement |
| (0.5, 0.5)  | 0.0       | 1, 0, 0, 0, 0 | **critical**: exact agreement in one step |
| (0.3, 0.7)  | 0.0       | 1, 0, 0, 0, 0 | critical (any a+b=1) |
| (0.9, 0.9)  | -0.8      | 1, -.8, .64, -.512, .41 | damped oscillation → 0 |
| (1.0, 1.0)  | -1.0      | 1, -1, 1, -1, 1 | **oscillates forever, never converges** |
| (1.2, 1.2)  | -1.4      | 1, -1.4, 1.96, -2.74, 3.84 | **diverges** |

These match the theorems exactly:

* `|q| < 1  ⇔  0 < a + b < 2`  → `err_tendsto` (convergence), `hum_tendsto`/`dec_tendsto` (consensus).
* `a + b = 1  ⇒  q = 0`        → `critical_one_step` / `critical_agree` (one-step agreement).
* `a + b = 2` (e.g. a=b=1)     → `q = -1`, oscillation, `no_convergence` (disproof).
* `|q| > 1`                    → `err_diverges` (instability).

## Consensus value

The gain-weighted quantity `S = b·h + a·d` is invariant (checked directly and proved as
`invariant`). Hence when the loop converges, both channels tend to `S/(a+b) = (b·h0 + a·d0)/(a+b)`
(theorems `hum_tendsto`, `dec_tendsto`). Example (a,b)=(0.2,0.3), (h0,d0)=(1,0):
consensus = 0.3·1/0.5 = 0.6, and indeed h(n),d(n) → 0.6.

## Counterexample hunt

The universal conjecture "every mutual adaptive feedback loop reaches agreement" is **false**.
The minimal explicit counterexample is `a = b = 1`, `(h0,d0) = (1,0)`: then `e(n) = (-1)^n`, so
`|e(n)| = 1` for all `n`. Formalised as `counterexample_abs` and `no_convergence`.

## OEIS

No integer sequence of independent interest arises; the dynamics are a one-parameter geometric
sequence `q^n`, so an OEIS search is not applicable.

All numerical claims above are consequences of the closed form proved in
`Catalog/Physics/CyberneticSymbiosis.lean`; they are recorded here only as orientation.
