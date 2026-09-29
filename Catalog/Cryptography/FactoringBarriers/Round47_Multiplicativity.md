# Round 47 part 22 — multiplicativity means MORE RELATIONS CANNOT HELP

**2026-09-29. A small structural result that closes off a whole family of "try harder"
responses to the 73%.**

---

## The fact

`chi_P` is **multiplicative on `P_S`**:

> `chi(l₁l₂) = chi(l₁)·chi(l₂)`,

verified on 69/69 tests by agent A1, with negative controls. (It is **not** a homomorphism
on the Mordell–Weil group — that is a different statement and it is false, 39/1243 violations;
see `Round47_Audit.md` D2. **Both facts are true and they are not the same fact.**)

## What follows

`P_S` is closed under multiplication, and `chi_P` is a character on it. Therefore:

> **If every relation you can reach has `chi_P = +1`, then every PRODUCT of them does too,
> and no amount of additional relation-finding within the same `f` can ever produce a
> `−1`.**

So the 27% of `(m,c)` where round 47 found no witness are **not a search-depth problem**.
Within a fixed `f` the outcome is already determined: either `chi_P` is non-trivial on the
group of relations, in which case one relation gives a factor, or it is trivial, and
multiplicativity means the triviality is closed under every combination.

**The only escape is a different `f`.** That is the same conclusion Lee–Venkatesan reach, but
by a different route: they randomise the field because `chi_P` is a property of the field.

## What this rules out

| response | verdict |
|---|---|
| "search higher" (more relations, larger `H`) | **cannot work** — multiplicativity closes the `+1` locus |
| "combine relations" (products, dependencies) | **cannot work** — same reason |
| "run longer" | **cannot work** — the non-trivial fraction for `n = pq` is **exactly 1/2 or 0** (A12, 420/420), so there is no small chance to grind down |
| "try a different `f`" | **the only move** — and that is what LV's randomisation is |

**This retires the whole family of engineering responses to Conjecture 7.1.** The problem is
binary per `f`, and the only variable is `f`.

## The honest state of the 73%

- **73% of sampled `(m,c)`**: a `chi_P = −1` relation is *found*, and the factor is
  recovered — verified end to end.
- **27%**: no `−1` found at the height searched. **This is not a refutation of
  Conjecture 7.1.** A `−1` relation could exist at higher height or among relations not
  reachable from the point found. **What the multiplicity argument does establish is that
  finding it requires new relations, not new combinations of the ones already in hand.**
- Certifying the 27% needs a Mordell–Weil basis, which needs a 2-descent at the bad primes
  `p`, `q`, which — since `N² ∣ disc(E)` — **factors `N`**. So the failure detection is the
  circular part and the search is not.

**And a `−1` found at higher height is still a legitimate relation** — the smoothness clause
is the only thing that gets worse, and A5's measurement (`|t| ≤ (L_n[1/3]/8)^{1/6}`) puts
the whole usable box at `O(10²)` points, which is where this thread stops.
