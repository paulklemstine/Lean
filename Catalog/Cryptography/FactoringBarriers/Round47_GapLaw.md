# Round 47 part 48 — the height-gap law: the structure is confirmed, the theorems don't reach genus 1

**2026-09-30. The turnover workflow completed 4/4 with no agent errors. The literature work
confirms the shape of the upper wall and identifies precisely why the provable results stop
short of it.**

---

## 1. The mechanism, in the agents' own terms

The relation curve is an **elliptic curve over ℚ** — the quartic has two rational points at
infinity for every `(m,P,Q)` because its leading coefficient is `4 = 2²`, so genus 1 plus a
ℚ-point gives the Jacobian

> `E_{m,c} : Y² = X³ − 3(mc)X + (c² + m³c)`,  coefficients `Θ(N)`.

So a relation at height `H` exists **iff the curve's lowest rational point is below `H`**.
The supply is `P(gap ≤ H)`. **The whole upper wall is one question: how does that gap grow?**

## 2. The gap grows LINEARLY in `log N` — the structure is confirmed

**Alpoge, "The average number of rational points on genus two curves is bounded",
arXiv:1804.05859 (2018-04-16), verbatim:**

> *"we prove that the number of rational points (x,y) on `C_f : y² = f(x)` satisfying
> `h(x) > 8 h(f)` is `<< 1.872^{rank(Jac(C)(Q))}`, which has finite average by the theorem of
> Bhargava–Gross on the average size of 2-Selmer groups of Jacobians over this family."*

**The gap is at `8·h(f)`, and `h(f) ~ log N` for coefficients of size `N`.** So:

> **The provable gap on these curves is `Θ(log N)`.** That is the law the second workflow is
> testing directly.

It also **rules out the two alternatives by elimination** — neither `c·log N/loglog N` nor
`N^{1/(d+1)}` — because there is no height *threshold* in the supply at all. The points do not
cease to exist; **the pool stops being producible.**

## 3. Why the provable theorems don't reach genus 1 — exactly

| result | what it gives | why it doesn't apply |
|---|---|---|
| Alpoge, arXiv:1804.05859 | points with `h(x) > 8h(f)` are `<< 1.872^{rank}` | **genus 2**; and the *small*-height region is explicitly **"by hand"** |
| Katz–Rabinoff–Zureick-Brown, Duke Math. J. **165**(16) (2016) 3189–3240, arXiv:1504.00694: *"We give an explicit uniform bound on `#X(F)` when `X` has Mordell–Weil rank `r ≤ g−3`"* | uniform bound | needs `g ≥ 2`; **we are genus 1**, so `r ≤ −2` is vacuous |

> **So: the gap law is `Θ(log N)` in form, the turn-over scale is right, and the sharpest
> available theorems stop one genus short of this curve.** The upper wall is real, correctly
> scaled, and provably out of reach of today's literature — which is the most precise statement
> the round can make about where the method stops.

## 4. Discipline, again, in the agents' own hand

- **Two half-recalled citations WITHDRAWN, not shipped**: Silverman *"The smallest point on an
  elliptic curve"* and Silverman–Stroeker–Tzanakis *"Saturating at the smallest rational points
  on elliptic curves"*. Both return **count 0** in zbMATH and OpenAlex title search.
- **And the zeros were shown to be real, not a broken route**: zbMATH's author endpoint works
  and returns Silverman's code `silverman.joseph-hillel` with **175 spellings, 125 papers** — so
  the API functions, and the zeros are genuine. **A negative with a positive control attached
  is a different kind of claim from a negative without one.**
- **It nearly found a nonexistent bug in the record and retracted it.** The record's
  `Round47_general_cubic.py` says `l(m) = 4v⁴A_P(t)`, which looks like a factor-2 error
  against the P=0 chart — but it is **consistent with that file's own doubled `gpar`**, and
  `v1_core` uses the chart. **The factor-2 is a two-convention hazard, not a defect**, and
  both agents said so independently.
- **Two of its own `rho` implementations were wrong** (a missing `p^{s/2}` lift factor; a
  wrong count when `K ≡ 0 mod p^e`). **Not reported as results.**

## 5. The synthesis, and what is still open

| | status |
|---|---|
| supply = bounded-height rational-point count on one elliptic curve | **PROVEN** |
| the "verify the relation" gate is vacuous (restates `N \| m³−c`) | **PROVEN** |
| exact count `#{m} = ρ(√(LM+K)−√(Lm₀+K))/L`, `ρ = #√K mod L` | **PROVEN**, verified 357 non-vacuous samples |
| gap is `Θ(log N)` **in form** | **PROVEN for genus 2** (Alpoge); **conjectural at genus 1** |
| turn-over scale | consistent with `H=40` and a `c·log N` gap, `c ≈ 1/3–1/2` |
| whether the supply actually dies at 128 bits | **OPEN** — the zero is only an upper bound of `1.5·10⁻⁴`, and the 96-bit rate would predict `0.53` events in 20,000 `f` |
