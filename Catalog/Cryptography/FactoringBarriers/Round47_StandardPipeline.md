# Round 47 part 24 — the STANDARD pipeline runs, factorisation-free, and does not close

**2026-09-29. The synthesis of the round, now demonstrated rather than argued. And the
decisive step is not closed, so this is a partial result, honestly labelled.**

---

## 1. What ran

Lee–Venkatesan p. 1: *"in implementations the NFS cannot assure the reduction from smooth
relations to a congruence of squares, because ideal factorisation is avoided in favour of
**Adleman's approach based on characters**."* **That pipeline is never run in this record.**
Round 47 only ran the *square-relation* pipeline. So I built the other one and ran it.

**Pipeline (ii), standard NFS, no factorisation of `N` anywhere:**

1. find `m`, `c = m³ mod N` with `c` small — trial division on `m`, no factoring;
2. factor base = small primes `ℓ`; collect the roots of `r³ = c` mod `ℓ`;
3. sieve for `a + bα` with `N(a+bα) = a³ + cb³` factor-base-smooth (trial division only);
4. `GF(2)` parity matrix, RREF, kernel `K` — pure linear algebra;
5. **Adleman's character test**: for `Q = (ℓ, α−r)`, `chi_Q(a+bα) = (a + br / ℓ)`, a Legendre
   symbol from `ℓ` and `r` alone. **No `p`, no `q`.**

**Results** (the tester's `p`, `q` are never fed to the pipeline):

| `N` | `m` | `c` | FB primes | relations | rank | `dim K` | character test non-trivial |
|---|---|---|---|---|---|---|---|
| 1333 | 20 | −2 | 26 | 85 | 26 | **59** | 39/59 |
| 1829 | 28 | −4 | 26 | 80 | 25 | **55** | 46/55 |
| 2537 | 57 | 8 | 42 | 190 | 29 | **161** | 159/161 |
| 5461 | 32 | −2 | 26 | 100 | 26 | **74** | 30/74 |

The kernel dimensions are large and the relations plentiful — which is the empirical
content of Lee–Venkatesan p. 39 (*"guarantees to find **every possible factor**"*) and the
answer to my own round-47 claim that relations were the binding constraint. **They are not.**

## 2. Why the loop is not closed, and it is NOT an implementation detail

The standard pipeline gives `Z = ∏(aᵢ + bᵢα) ∈ Z[α]` with `N(Z) = y²`. To get
`x² ≡ y² (mod n)` you need **`(Z) = (g)²` as an ideal**, hence `Z = g²·u` with `u` a unit —
and the two things that stop you are exactly what Bühler–Lenstra–Pomerance list:

> (6.4) *"Even if `∏(a+ba)O = γ²O` for some `γ ∈ O`, **it is not necessary that**
> `∏(a+ba) = γ²`."* … *"if `O` is a principal ideal domain and we have an explicit basis for
> the unit group … we can handle the obstruction (6.4) by linear algebra … **However, in
> general we cannot make any of these assumptions.**"*

Plus `Z[α] ≠ O` (6.5) and irreducibles ≠ primes (6.2). **That is the gap, and it is a
statement about the arithmetic of `O_K`, not about my code.**

## 3. The synthesis — this is the round's actual shape

| framework | how non-triviality is reached | cost |
|---|---|---|
| **square relations** (LV) — what round 47 built | `l(α) = g²` **elementwise**, so every relation is already a congruence of squares and the character is per-relation | the relation space is a **curve for every `d`**, genus 1 at `d=3`, **5 at `d=4`**; 73% at `H=60`; **no smoothness needed**, but too few relations |
| **norm relations + character** (Adleman, what implementations use) | `(Z) = (g)²` **ideally**, so the character is per-dependency and the kernel is huge | relations abundant, `dim K` = 55–161 as measured; but needs the **class group and units**, and BLP's own termination argument is *"heuristically bounded"* with *"reasonable to conjecture"* |

> **Each framework buys exactly what the other cannot afford.** Square relations get
> elementwise squares — and pay for it with a codimension-`(d−2)` locus. Norm relations keep
> a `d`-dimensional space and a large kernel — and pay for it with the class group, the unit
> group, and `Z[α] ≠ O`.
>
> **Round 47 discovered the first price without seeing the second. Neither is a method, and
> the reason is the same in both: the congruence of squares is what you are trying to
> produce, and every route to producing it costs more in relations than the supply can bear.**

## 4. A bug the self-test caught, in the TEST

The first version of self-test S1 asserted that a cubic `r³ = c` mod `p` has no root besides
a known one. **That is false** — with one root the quadratic factor can split, giving three.
`ring`-style algebra over a field has the same trap. The control flagged it before the
pipeline ran. **Third time today that a self-test caught a defect in the instrument rather
than the experiment** (the first was the `L`-pricing exponent, the second a stubbed-out
group-law loop).

## 5. Status

**RUNS, NOT CLOSED.** The standard pipeline executes end-to-end with no factorisation of `N`,
produces abundant relations and a large kernel, and applies Adleman's character test. **The
decisive gcd is not obtained in this framework, and the reason is a theorem about `O_K`**
(BLP 6.2–6.5), not a gap I can close by writing more code.
