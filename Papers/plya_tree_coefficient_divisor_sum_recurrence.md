# Computational Evidence: Pólya tree coefficient divisor-sum recurrence

## Object
Let `a(n)` be the number of unlabelled rooted trees on `n` nodes (Pólya trees),
OEIS **A000081**. Pólya's enumeration gives the divisor-sum (Euler-transform)
recurrence: with `c(k) = ∑_{d | k} d·a(d)`,
```
n · a(n+1) = ∑_{k=1}^{n} c(k) · a(n+1−k),   a(1) = 1.
```

## Small-case calculations (computed in Lean)
We defined `a` directly by the recurrence (with natural-number division) and evaluated:

```
a(0..15) = [0, 1, 1, 2, 4, 9, 20, 48, 115, 286, 719, 1842, 4766, 12486, 32973, 87811]
```

This matches **A000081** exactly: 1, 1, 2, 4, 9, 20, 48, 115, 286, 719, 1842, 4766, ...

## OEIS
- **A000081** — Number of rooted trees with n nodes. First terms 1, 1, 2, 4, 9, 20, 48, 115, 286, 719.

## Integrality / exactness hunt
The recurrence divides by `n`, so for the natural-number definition to coincide with
the true counts the sum `∑_{k=1}^{n} c(k)·a(n+1−k)` must be divisible by `n`. We checked
the multiplied-out identity `n·a(n+1) = ∑ ...` (no division) for `n = 1..13`:
all `true`. No counterexample found — the divisor-sum recurrence is integral on the tested range.

## Conclusion
The recurrence is faithful to A000081 and integral on the tested range. The Lean file
proves: (1) the value table, (2) the exact divisor-sum identity on a verified range, and
(3) a fully general statement that the construction satisfies the recurrence (with `Nat`
division) for *all* `n`.
