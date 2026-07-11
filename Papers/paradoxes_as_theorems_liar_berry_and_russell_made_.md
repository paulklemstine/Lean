# Computational Evidence — Paradoxes as Theorems

## 1. The negation-fixed-point census

Belnap negation `neg` acts on the four values as `T↦F, F↦T, B↦B, N↦N`.
Enumerating all values and testing `neg v = v`:

| value | neg value | fixed? | designated (`isTrue`)? |
|-------|-----------|--------|------------------------|
| T     | F         | no     | yes                    |
| F     | T         | no     | no                     |
| B     | B         | **yes**| **yes**                |
| N     | N         | yes    | no                     |

There is exactly **one designated fixed point of negation: the glut `B`.**
For Boolean negation the same census gives `true↦false, false↦true` — **zero**
fixed points. This single table is the whole reason the paradoxes need
paraconsistency, and is exactly what `isTrue_neg_fixpoint` and
`bool_no_neg_fixpoint` encode.

## 2. The six-sentence model, evaluated

```
truth  = [B, B, B, T, F, N]   -- indices 0..5
sentNeg= [0, 1, 2, 4, 3, 5]
```

Coherence check `truth (sentNeg i) = neg (truth i)` for every `i`:

| i | sentNeg i | truth (sentNeg i) | neg (truth i) | match |
|---|-----------|-------------------|---------------|-------|
| 0 | 0 | B | neg B = B | ✓ |
| 1 | 1 | B | neg B = B | ✓ |
| 2 | 2 | B | neg B = B | ✓ |
| 3 | 4 | F | neg T = F | ✓ |
| 4 | 3 | T | neg F = T | ✓ |
| 5 | 5 | N | neg N = N | ✓ |

## 3. Soundness / non-explosion checks

- Provable set `{0,1,2,3}` designated values: `B,B,B,T` — all designated ⇒ **sound**.
- Falsehood `4` has value `F` (undesignated) and is **not** provable ⇒ explosion
  fails (a glut does not designate everything).
- Number of gluts = `#{0,1,2}` = **3** ⇒ inconsistency degree 3.

## 4. Counterexample hunt

We searched for a *two-valued* (Boolean) coherent assignment making a
self-negating sentence designated. Enumerating both Boolean values against
`truth (sentNeg s) = ! truth s` with `sentNeg s = s` forces `b = !b`, which has
**no solution**. This confirms the classical impossibility (`classical_no_sound_liar`)
rather than refuting the four-valued construction.

All the finite facts above are discharged by exhaustive evaluation in the formal
development; no unverified numerical claim is relied upon.
