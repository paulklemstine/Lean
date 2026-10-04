# Round 105 — audit of the round-103c semiprime wall: same conclusion, corrected reasoning

**2026-10-04. No exponent beaten. This round audits my own most recent structural
claim. Round 103c concluded "the rough-semiprime packing forces γ → 1/2" — the
CONCLUSION is right, but the PREMISE was wrong. The corrected argument is a
covering-design bound, which reaches the same wall for the right reason. Recorded
because the record's value is in the reasoning being right, not just the number.**

Companion: `Experiments/UMWWindow/pair_covering.py` (deterministic, `out_paircover.txt`).

---

## 1. The error in round 103c

Round 103c asserted:

> "Each rough semiprime `i = p·q` needs a **single** difference divisible by `i`'s
> entire factorization… so a cover is a **packing of rough semiprimes**."

This premise is **false**. A difference `d` whose prime factorization contains
`p, q, r, s` covers **six** semiprimes (`pq, pr, ps, qr, qs, rs`), not one. One
difference absorbs many rough semiprimes — so a semiprime *count* is not the right
obstruction, and the round-103c mechanism (as stated) does not hold.

## 2. The correct argument: a pair-covering design

To cover the target `i = p·q`, a difference must contain **both** primes `p` and
`q`. So the prime set of each difference is a **block**, and the blocks must cover
every relevant **pair**:

* `P = {primes in (n^γ, n]}`, `v = |P| ~ n/ln n`.
* A difference `d ≤ exp(n^γ)` contains at most `k ~ n^γ/ln n` primes of `P`
  (a product of `r` such primes is `~n^r ≤ exp(n^γ) ⟹ r ≤ n^γ/ln n`).
* The blocks must form a **set-pair-covering design** `C(v, k, 2)`.

By the standard (Schönheim) pair-covering bound, the number of blocks satisfies

$$ b \;\ge\; \frac{\binom{v}{2}}{\binom{k}{2}} \;\sim\; \left(\frac{v}{k}\right)^{2} \;=\; n^{\,2-2\gamma}, $$

while the algorithm has at most `b ≤ n^{2γ}` differences. Feasibility requires

$$ n^{2\gamma} \;\ge\; n^{2-2\gamma} \;\;\Longleftrightarrow\;\; 4\gamma \ge 2 \;\;\Longleftrightarrow\;\; \boxed{\gamma \ge \tfrac12}. $$

Measured (`out_paircover.txt`), the feasibility flips exactly at `γ = 0.5`.

## 3. What this does and does not change

* **The conclusion stands:** `γ ≥ 1/2` (exponent `1/4`) — now derived from a
  **covering design** rather than a (false) semiprime count.
* **This is a second, mechanism-independent wall** at `γ = 1/2`, alongside the
  round-96b birthday obstruction (residue collisions). Two unrelated combinatorial
  constraints — one about *which pairs of primes appear together in a difference*,
  one about *residue collisions mod `i`* — both force the same threshold. That
  agreement is the substantive result.
* **Not claimed:** that no cover exists. Two independent necessary conditions both
  force `γ ≥ 1/2`; the Umans–Wang conjecture is exactly the claim that a cover
  exists below this, and it remains open.

**Why this audit matters.** Rounds 103c→105 show the record doing its job: a claim
was made on a false premise, the premise was caught by re-derivation, and the
result was re-established on correct grounds. The number did not move, but the
**reason** is now sound — which is the difference between a heuristic barrier and
a proof. (Cf. the record's own repeated theme: "re-cost against the largest
term," "a 'discovery' about a paper you have read is not a discovery until you
re-read the page.")