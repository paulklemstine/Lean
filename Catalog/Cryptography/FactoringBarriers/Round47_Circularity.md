# Round 47 part 6 — a structural circularity in my own method, found and stated

**2026-09-29. This qualifies `Round47_MordellWeil.md` §3 and §5. I found it myself; an
adversarial audit agent was dispatched on the same question and had not yet reported.**

---

## 1. The fact

The Jacobian of the relation quartic is `E : Y² = X³ − 3(mc)X + (c² + m³c)`, so `a = −3mc`
and `b = c² + m³c = c(c + m³)`. Its discriminant is **exact**, not asymptotic:

> **`disc(E) = 4a³ + 27b² = 27c²(c − m³)²`**

Verified symbolically (`sympy.expand` then `factor`, difference identically zero) and
numerically over 3481 pairs `(m,c) ∈ [1,60)²` with **0 violations**.

And `c = m³ mod N` means `c − m³ = −kN` for an integer `k`. Therefore

> **`disc(E) = 27c²k²N²`  ⟹  `N²` divides `disc(E)`  — always.**

Confirmed on the actual instances: `N = 1333, 2201, 2537, 5461, 3053`, `(m³−c)/N` =
6, 3, 1, 4, 5, and `disc(E) = 27c²k²N²` exactly in every case.

## 2. Why it matters

**The bad primes of `E` are exactly `p` and `q` — the two primes the method is trying to
find.** This is not a coincidence of the model: the NFS setup *requires* `f(m) ≡ 0 (mod N)`,
so `p` and `q` are roots of `f`, and they are precisely the primes at which the relation
curve has bad reduction.

A Mordell–Weil **basis** needs an upper bound on the rank, and the standard one — the
2-Selmer group — needs local data at the bad primes, i.e. it needs `p` and `q`.

> **The "compute a basis, read `chi_P` off it" step of Algorithm 47 may therefore be
> circular**, and the 12/12 table is **not** evidence against that: at `N ≤ 18191` the
> factorisation costs nothing, so an honest method and a circular one are indistinguishable
> at that scale. The table was only ever evidence of *correctness of the algebra*, never of
> *absence of circularity*, and I should have said so when I filed it.

## 3. What survives, and what does not — the honest split

**SURVIVES — the factoring step is not circular.** To factor `N` one needs **one** rational
point `P` of the genus-1 curve with `chi_P(P) = −1`. Producing such a point needs:

- rational points of `E_gen : y² = A(t)`, obtainable by any height search — including the
  record's own brute-force `(u,v)` enumeration, which uses no factorisation; and
- a **Jacobi symbol**, `chi_P = Jacobi(C(t)·y, N)`, computable without knowing `p` or `q`.

Neither step touches `p` or `q`. **So: find such a point, and `gcd(w − g(m), N)` returns a
factor.** That direction is sound.

**DOES NOT SURVIVE — the "detectable failure" claim.** `Round47_MordellWeil.md` §5 says
the 38% failures are *detected* because `chi_P` is trivial on `E(Q)` exactly when it is `+1`
on a basis. Certifying a *basis* needs the rank upper bound, hence the 2-Selmer group, hence
`p` and `q`. **That half of the claim is circular and must be struck.**

**Also suspect: the 62%.** It was measured by computing PARI bases. If PARI's descent used
the factorisation internally, the sample may be biased toward instances where it succeeded.
At these sizes that is probably harmless, but the figure should be read as "the algebraic
construction works on 62% of the sampled `(m,c)`", not as a runtime claim.

## 4. What this does to the round's headline

Honestly, it moves it. The claim reduces from

> ~~"a constructive procedure for the obstruction, with decidable failures"~~

to

> **"a characterisation of the obstruction as a group-theoretic triviality on an explicit
> cubic, plus a verified algebraic reduction from any point with `chi_P = −1` to a factor of
> `N`."**

The second is real and it is new. The first was overstated.

**And the uncomfortable part, stated plainly:** the non-circular half — produce a rational
point of the quartic with `chi_P = −1` — is *close to what the record already does*, which
searches `(u,v)` and computes the branch. What round 47 adds there is the **structure**:
that the search space is a genus-1 curve, that its Jacobian is `E` in closed form, and that
the character has an explicit formula. Whether that structure buys an **asymptotics** win is
**not established**, and nothing in round 47 shows it does.

## 5. The one thing that would make it a method

The rank computation is the cost, and the bad reduction at `p`, `q` is what may make it
circular. The way out is a descent that does **not** require local data at the bad primes —
or a curve isomorphic over `Q` to one of good reduction away from `p, q`. **Whether such a
model exists is not examined here, and it is the sharp next question.** Note that the bad
reduction is intrinsic (the 12th-power-class of the minimal discriminant is an invariant), so
this is a real constraint and not a presentation artefact.
