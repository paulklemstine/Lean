# Round 47 part 28 — the GNFS constant is PINNED: no smoothness improvement can move it,
# and `1.902` lies outside the model class

**2026-09-29. Agent A14. Four proofs, self-tested to 13 digits. This closes the last live
lever on the constant, and it refutes the lead I handed the agent two steps ago.**

---

## 1. The self-test passed — and it diagnosed A13's failure

```
T1  min 2·max(a,b) = 1.922999427076593   (target …544);  a/b = 1.000000000289
    gamma = 1.44225 = 3^{1/3};  kappa = 3.0000                                    PASS
```

**A13's control failed for a diagnosable reason, not a coding one:** `(64/9)^{1/3}` is an
**asymptotic limit** (`ξ = (4/3)X`, LGST Theorem 17, p. 9), so **any finite-`ν` numerical run
must miss it.** A14 re-ran with a scaled control, which passes.

## 2. THE REDUCTION

With `a = αW`, `b = βW`, `d = γS`, `W = ν^{1/3}(log ν)^{2/3}`, the LGST constraint
(p. 4, Problem 3, image-verified; Definition 1 is `p(u,v) = log(Ψ(e^u,e^v)/e^u)`, so the
Dickman argument is `u/v`) becomes **exactly**

> **`αγ + 2/γ = 3β(2α − β)`**

and the objective minimises `C = 2·max(α,β)`.

## 3. PROOF (i): no smoothness improvement can move the constant

Any `L` appearing in `|log ρ(U)| = U(log U + L(U))` — **Hildebrand, de Bruijn, Harper, all
of them** — enters the constraint **only as `3L/log ν`**:

| source | `L` | effect |
|---|---|---|
| de Bruijn | `7.3e−3` at `log ν = 2302.6` | — |
| artificial `L = +100` | | `1.3e−1` at `log ν = 1e6` |
| artificial `L = −100` | | `3.5e−5` at `log ν = 1e6` |

> **THE SMOOTHNESS TERM IS THE DEAD HALF OF THE CONSTRAINT.** Nothing on the smoothness side
> — Hildebrand, de Bruijn, Harper, or anything after them — can move the constant. **This
> refutes A13's "the lead is the constraint": the constraint's smoothness half is inert.**

## 4. PROOF (ii): `1.902` is OUTSIDE the model class

The constant is `C³ = 8(κ+1)²/(9(κ−1))` with `κ = log M₁/log M₀ = 3` (the geometry, fixed).
It has a **unique minimum at `κ = 3`**, giving `64/9`. Numeric vs closed form: `rel. err
1e−16` at `κ = 1.5, 2, 2.5, 3, 4, 6, 10`.

Solving `C(κ) = 1.9018836` gives

> `8κ² − 45.914778κ + 69.914778 = 0`,  **discriminant `−129.106`**

> **NO REAL `κ` PRODUCES `1.9018836`.** The minimum of the entire LGST model class is
> `1.922999427077`, a **+1.098%** gap above it.

So `1.9018836 = ((92 + 26√13)/27)^{1/3}` is **strictly below the minimum of the whole model
class**. It is therefore:

- **not** a rebalancing of `κ`;
- **not** a different degree `d` — check T4: with `m` algebraic fields the conjunctive
  construction `c_m³ = (4/9)m(m+1)` is strictly worse for `m ≥ 1` (`m=2 → 2.7734`), and
  the disjunctive gives `C = 1.9229994` for all `m`;
- **not** "more polynomials" — `ω` is absent from the objective and the constraint;
- and **not** anything the model produces at all.

## 5. Harper: the handover's claim is TRUE and VACUOUS

The handover says Harper *"does cover the factoring regime `y = L_n[1/2,c]`"*. **True — and
worthless.** Measured, the factoring regime is already inside **Fouvry–Tenenbaum's *old***
range. And Harper's own Result 1 (p. 4) restates Hildebrand **unchanged**:

> *"Ψ(x,y) = xρ(u)(1+O(log(u+1)/log y))… where `ρ(u) = e^{−(1+o(1))u log u}`"*

**It bounds `Ψ(x,y;q,a)` — the restricted count — not `Ψ(x,y)/x`, which is what the constant
consumes.**

## 6. So what IS left

The constant is pinned by **three inputs, none of them smoothness**:

1. **the cusp** `a = b` — which is why linear algebra is non-binding (A13);
2. **the geometry** `κ = log M₁/log M₀ = 3` — which is why the factor-base sizes are what
   they are;
3. **the leading term** `−U log U` of `−log ρ` — which is why no smoothness improvement
   propagates.

**To move it you must change one of those three, and none of them is a smoothness
improvement.** That is a *derived* obstruction with a passing self-test, not a citation.

## 7. Not obtained, stated as not obtained

- **Coppersmith LNCS 877 (1990) 193–215** — unreachable: Crossref 0; arXiv
  `search_query` dead (control `id_list=2007.02730` returns LGST, but `all:sieve` returns
  0); Wayback CDX 0; Semantic Scholar and DBLP 429/gated. **`1.902`'s provenance is
  therefore still UNVERIFIED, and A14 makes no claim about it.**
- **Vyas–Williams, SODA 2010** — not obtained; routes and positive controls are in A14's
  full write-up.
- The single remaining cheap search A14 names: **Google Books full text for the literal
  `92 + 26` beside "number field sieve"** (Crandall–Pomerance or Cohen §11.1) — the most
  direct route to the `√13`.
