# Round 47 part 30 — the group-law escape is TESTED and it is INERT: 0/192

**2026-09-29. The last idea in the round, run properly. The logical correction to my
multiplicativity claim stands; the idea it suggested does not work.**

---

## 1. The correction was right; the hope it created was not

`Round47_MultiplicativityCorrection.md` is **kept**: `chi_P` is not a homomorphism on
`E(Q)` (audit D2, 39/1234), so the `+1` locus is closed under *multiplication* and not
under the *group law*. That is logic and it stands.

**What does not stand is the empirical hope.** I ran the test: restrict to exactly the
instances the 73% height-search **misses** — those with `chi_P(P) = +1` at the base point —
and ask whether the group law reaches `−1`.

> **192 base points with `chi_P = +1`.  The group law reached `chi_P = −1` at some `nP` in
> 0 of them (n ≤ 14). 0 factors recovered.**

## 2. ⚠️ And an earlier "success" of mine was a sign bug

My first run of this test reported **"8/8 escaped to `−1` at n = 3."** **That was wrong, and
the bug is instructive.**

I had written `c = −(m³) mod N`, but the relation condition is `f(m) = m³ − c ≡ 0 (mod N)`,
so it is `c = +m³ (mod N)`. With the wrong sign the "relation curve" was the curve for a
different field entirely — so of course it had nothing to do with the actual relations, and
of course it showed a pattern.

**The tell was there and I did not read it:** the identity `w² ≡ g(m)² (mod N)` failed, with
`w² − g(m)² ≡ 79 (mod N)` for `N = 1333`. **The relation was not a relation, and the
pipeline asserted `w*w == lm` — a check that passes for an invalid relation just as happily
as a valid one.** The check that would have caught it is the congruence `w² ≡ g(m)² (mod N)`,
and I only ran it *after* seeing the gcd fail.

> **Six self-caught errors today, and this is the one where the test I had was the wrong
> test.** A self-test is only worth the identity it actually checks. `w² = l(m)` is an
> integer identity that holds for every parameter set; `w² ≡ g(m)² (mod N)` is the one that
> says the relation is real.

## 3. What the corrected pipeline does establish

With `c = +m³ (mod N)` the pipeline is sound, and on the instances brute force **finds**:

> **66/66 factors recovered**, descent-free — no `ellrank`, no factorisation of `N` anywhere.
> `p` and `q` were computed only to grade the answer; the procedure never saw them.

But every one of those had `chi_P = −1` **at n = 1** — the base point. So it is the **73%**,
re-measured end-to-end, not a rescue of the other 27%.

## 4. The state, stated exactly

| | |
|---|---|
| Brute-force `(u,v)` height search, `H = 60` | **`chi_P = −1` in 73% of `(m,c)`; factor recovered** |
| Group law from a `+1` base point, `n ≤ 14` | **0/192** — inert |
| Certifying that the 27% *never* has a `−1` | needs a Mordell–Weil basis → a 2-descent at `p`, `q` → **factors `N`** |

**So the honest position is unchanged and now sharper: a factorisation-free, descent-free
procedure that works on 73% of instances and has no factorisation-free way to certify the
other 27%.** Whether a *different* `f` always works is Conjecture 7.1, and it is open.

**That is the round's end state.** I have run the last idea I have, it failed, and the
failure is measured rather than argued.
