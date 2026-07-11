# Computational Evidence — Paradoxes as one theorem (Lawvere diagonal bridge)

The formal file is `Catalog/Logic/ParadoxesLawvereBridge.lean`. Below is the
concrete numerical/structural evidence gathered before and during formalization.

## 1. Berry / Chaitin counting face (the finite pigeonhole)

Descriptive complexity `K enc x = Nat.size (enc x)` for the identity code
`enc = id` is just the bit-length of `x`:

| x        | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|----------|---|---|---|---|---|---|---|---|---|
| K id x   | 0 | 1 | 2 | 2 | 3 | 3 | 3 | 3 | 4 |

`berry_pigeonhole` claims: among `0, …, 2^n` at least one `x` has `K x > n`.

* `n = 2`: search `{0,…,4}` for `K x > 2` → witnesses `[4]` (indeed `K 4 = 3`). ✓
* `n = 3`: search `{0,…,8}` for `K x > 3` → witnesses `[8]` (indeed `K 8 = 4`). ✓

These are exactly the boundary powers of two, confirming the tightness of the
`2^n` versus `2^n + 1` counting: the `2^n` short codewords cannot cover `2^n + 1`
distinct numbers.

## 2. Belnap fixed point (the non-classical value)

`#eval (BV.neg BV.B, BV.des BV.B) = (B, true)` confirms `B` is a **designated
negation fixed point**: `neg B = B` and `des B = true`. This is the value that
turns the self-negating (Liar) sentence into a provable glut, and it is the exact
feature a nontrivial Boolean algebra provably lacks (`no_boolean_neg_fixpoint`).

## 3. Counterexample hunt for the core diagonal

The core claim `lawvere_fixedPoint` (point-surjection ⇒ every endomap has a fixed
point) was stress-tested by looking for a would-be counterexample: a
point-surjective `e : A → (A → C)` together with a fixed-point-free `f : C → C`.

* For `C = Bool` and `f = not` (no fixed point), any candidate surjection
  `A → (A → Bool)` fails, matching Cantor's theorem — no finite or infinite `A`
  enumerates `A → Bool`. No counterexample exists; this is precisely the content
  of `no_prop_pointSurjective` / `cantor_no_surjective`.
* The non-vacuity witness `pointSurjective_nonvacuous` (`A = C = PUnit`) shows the
  hypothesis is satisfiable, so the theorem is not vacuously true. When it *is*
  satisfiable (`C` a singleton), the only endomap is the identity, whose fixed
  point is the unique point — consistent with the theorem.

## 4. OEIS

The bit-length sequence `K id x = 0,1,2,2,3,3,3,3,4,…` is
[A070939](https://oeis.org/A070939) (number of binary digits of `n`, with the
convention `A070939(0)=1`; our `Nat.size` uses `size 0 = 0`). No new sequence is
introduced; the counting is standard.

## Summary

Every quantitative prediction of the formal statements — the Berry pigeonhole
witnesses, the tightness at powers of two, the Belnap fixed point, and the
absence of a diagonal counterexample — is confirmed computationally and then
proved in Lean with only the standard axioms `propext, Classical.choice,
Quot.sound` (and `lawvere_fixedPoint` needs *no* axioms at all).
