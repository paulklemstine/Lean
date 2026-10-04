# Round 106 — the base-d deterministic finish: a genuinely new mechanism, honestly priced

**2026-10-04. No exponent beaten. This round implements, from first principles, the
most novel recent deterministic factoring *mechanism* — Pomykała–Jurkiewicz's
base-`d` finish (arXiv:2503.00950, 2025) — verifies it, and prices it against the
frontier. It is a real, distinct algorithm; it is not a complexity improvement.**

Companion: `Experiments/UMWWindow/based_finish.py` (deterministic).

---

## 1. Why this mechanism

Rounds 96–105 attacked the Umans–Wang divisor-cover / Coppersmith / lattice
family. The base-`d` finish is **structurally different**: it is a *decoding* step
on the multiplicative-group orders mod `p` and `q`, with no lattice, no small-root
lattice, and no smoothness-of-polynomial-values machinery. It is worth testing
on its own terms.

**The mechanism (from the paper).** Over `Z_N = Z/pq`, take an element `α` (or a
point `Q` on a curve) whose orders `ord_p(α)` and `ord_q(α)` are **2-adically
separated** (`v_2` differ). If `d = max(ord_p, ord_q)` has largest prime factor
`≤ t`, then `N = p·q` is recovered **deterministically in `t^{1+o(1)}`** time by
writing `N` in base `d` and decoding. This is a genuinely new deterministic
finish (the paper improves an earlier `t^{2+o(1)}` decoding to `t^{1+o(1)}`).

## 2. Implemented and verified

The script implements the base-`d` digit encoding/decoding and the
separated-order recovery from first principles and verifies:

* **The paper's own worked example** decodes exactly:
  `N = 3839985129719 = 1959583 × 1959593` with `d = 2⁷·3⁷ = 279936`, `B = 3`.
* **Six synthetic separated-order instances** (20-bit `p`, `q`; `dp`, `dq` with
  differing `v_2`) are all recovered deterministically.

So the *mechanism is real and correct* — this is a working implementation of a
2025 deterministic factoring primitive, not a heuristic sketch.

## 3. Honest price: a cleaner finish, not a faster search

The finish costs `t^{1+o(1)}` — cheap. But `t` is the largest prime factor of the
separated order, and **finding** a separated order whose magnitude is
`t`-smooth is exactly the smoothness lottery that prices ECM / Pollard-`p¹` at
`L(1/2)`. To reach Harvey's `N^{1/5}` the finish would need `t < N^{1/5}`, i.e.
an `N^{1/5}`-smooth separated order — a search still in the `L(1/2)` regime.

> **Verdict.** The base-`d` finish is a **cleaner deterministic DECODING** of a
> separated smooth order — a real advance in *how* you finish, worth a paper —
> but it does **not** beat the `L(1/2)`-vs-`N^{1/5}` barrier, because that barrier
> lives entirely in the *search* for a suitable order, which base-`d` inherits
> unchanged from ECM.

This is consistent with round 98's frontier census: Pomykała–Jurkiewicz's overall
bound is the **conjectural `L(√2)`** (worse than ECM's `L(1/2)`); this round
implements the rigorous `t^{1+o(1)}` *finish* kernel and confirms that the
bottleneck is the order-smoothness search, not the decoding.

## 4. What this adds

* A **from-scratch verified implementation** of a 2025 deterministic factoring
  primitive (base-`d` decoding), including reproduction of the paper's example —
  reusable infrastructure the repo did not have.
* An honest separation of **finish** (new, cheap, deterministic) from **search**
  (inherited ECM barrier), which is the correct way to price this mechanism
  against the frontier.

## 5. Honest scope

* **No exponent beaten.** The base-`d` mechanism is genuinely new but sits behind
  the same order-smoothness wall as ECM; it is not a complexity improvement.
* **Not claimed:** that base-`d` can be driven faster than `L(1/2)`; only that
  the finish is verified and the bottleneck is the search, as priced above.

**Where this leaves the program.** With rounds 96–105 (UMW window closed by two
independent walls, residue method characterized, machine-checked GAP theorem,
budget guard) and round 106 (base-d implemented and priced), every *deterministic
and ECM-family* route now has either a wall or an honest price. A genuine
frontier move would have to change the **search** for a suitable object — not the
decoding, not the lattice, not the covering. That has not been achieved in ~21
rounds, and I have no mechanism in mind that survives scrutiny.