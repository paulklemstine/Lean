# Round 47 part 17 — the two Lee–Venkatesan constants, read off the page

**2026-09-29. Resolving the open question from `Round47_GNFSConstant.md` §5, by rendering
the page rather than trusting the text layer. The agent's number was right and its
attribution was wrong; both are corrected here.**

---

## What the page actually says

**Theorem 2.3 (p. 5)**, read from a 400 dpi render of arXiv:1805.08873 p.2:

> `L_n( 1/3, ∛(64/9) + o(1) )  ≃  L_n( 1/3, 1.92299… + o(1) )`

**That is the theorem, and it is the ordinary GNFS constant, not `1.90188`.** The agent
reported "LV's *rigorous* randomised MPS gives `1.90188`" as if it were the headline; it is
not. The headline is `1.92299`.

**The `1.90188` is a separate parenthetical**, in the same section, prefixed:

> *"These results can be shown to extend to Coppersmith's multiple polynomial sieve of [9], a
> randomised variant of which finds congruences of squares modulo `n` in expected time:"*

> `L_n( 1/3, ∛((92 + 26√13)/27) + o(1) )  ≃  L_n( 1/3, 1.90188… + o(1) )`

Verified: `∛((92 + 26√13)/27) = 1.901898…`, matching the printed `1.90188` to five decimal
places.

## The two claims, stated correctly

| | constant | what it is | status |
|---|---|---|---|
| **Theorem 2.3** | `∛(64/9) = 1.92299` | the paper's actual rigorous NFS result | **proven, conditional on Conj 7.1** |
| **the extension remark** | `∛((92+26√13)/27) = 1.90188` | "results **can be shown to extend to**" Coppersmith's MPS, *a randomised variant* of which | **asserted, not proven in the paper; and for a randomised variant** |

**So the premise correction survives, with its scope fixed:** `1.923` **was** beaten, to
`1.90188`, and the beating is recorded **by Lee–Venkatesan themselves**, in the same
section as their theorem. But it is a remark asserting an extension, not a theorem they prove.

## ⚠️ A digit coincidence that is a trap

`RESEARCH.md`'s executive summary records a **different** `1.901884` — a **withdrawn** two-point
extrapolation of a saturating `1/k` arity law to a floor `≈1.8808` — and **explicitly
withdraws it**.

**A withdrawn extrapolation that agrees to four digits with a real, printed, unrelated
constant is the single most confusable object in this file.** Any future citation of
"1.90188" here must say **which** of the two it means. The withdrawn one is an extrapolation
and is retracted; the real one is Lee–Venkatesan's Coppersmith-MPS extension remark.

## What is now settled about the frontier

- **`1.92299` is the proven rigorous constant**, conditional on Conj 7.1. Nothing here
  improves it.
- **`1.90188` is asserted for a randomised variant**, not proven, and — per
  `Round47_GNFSConstant.md` §2 — the linear-algebra half of *any* constant is the
  irreducible `O(n²)` term in Montgomery's method.
- **Neither is reachable by the routes this record has tried.** The two closures stand:
  the `O(n²)` is the constant, and a polylogarithmic win is swallowed by the `(1+o(1))`.

## Method note, and it is the third time today

`pdftotext -layout` on this page renders the two formulas as

```
Ln ( 1/3 ,  92 + 26 13  )  ≃  Ln ( 1/3 , 1.90188 ... + o(1) )
     3      27
```

— which is **wrong in both formulas**: it drops the cube root, drops `√`, and splits the
fraction. Reading it as text would have given `(1/3)(92/27 + 26/13) = 2.47`, and the
"1.92299 vs 1.90188" distinction would have been missed entirely. **The page image is the
only version of this document that can be trusted**, and it has now been read twice, with
different crops, both times changing a conclusion.
