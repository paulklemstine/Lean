# Future Directions — The Lattice of the Fibonacci Rank of Apparition

## Synthesis

This cycle isolated a single organizing principle behind the Fibonacci divisibility
folklore: the **rank of apparition** `z(m)` (least positive `k` with `m ∣ F k`) is a
*complete divisibility invariant*. The catalog's biconditional
`m ∣ F n ↔ z(m) ∣ n` (`FibApparition.fib_dvd_iff_apparitionRank_dvd`, in
`Novelty/FibApparitionExistence.lean`) behaves like an **adjunction** between the
divisibility poset on moduli and the divisibility poset on indices, with `z` the left
adjoint of `n ↦ F n`. From this one law we derived, in `Novelty/FibApparitionLattice.lean`
and with `sorry = 0`:

- `eq_of_forall_dvd_iff` — naturals dividing the same set are equal (the uniqueness tool);
- `apparitionRank_dvd_of_dvd` — `a ∣ b ⟹ z(a) ∣ z(b)` (monotonicity for `∣`);
- `apparitionRank_lcm` — `z(lcm a b) = lcm (z a) (z b)` (the join-homomorphism law);
- `apparitionRank_mul_coprime` — `z(ab) = lcm (z a) (z b)` for coprime `a, b`;
- `apparitionRank_eq_one_iff` — `z(m) = 1 ↔ m = 1` (detection of the unit).

The conceptual payoff is that `z` is a homomorphism of join-semilattices, so the rank is
*determined by its values on prime powers* — exactly the structural fact the classical
literature treats as a computational convenience. The proofs use no Fibonacci recurrence;
they are pure order theory once the adjunction is in hand.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `apparitionRank_dvd_of_dvd` | `0 < b → a ∣ b → z a ∣ z b` | proved |
| `apparitionRank_lcm` | `0<a → 0<b → z(lcm a b) = lcm (z a)(z b)` | proved |
| `apparitionRank_mul_coprime` | coprime `a,b ⟹ z(ab)=lcm(z a)(z b)` | proved |
| `apparitionRank_eq_one_iff` | `0<m → (z m = 1 ↔ m = 1)` | proved |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The meet side: a formula for `z(gcd a b)`

We proved `z` is a *join* (lcm) homomorphism but deliberately stopped there, because the
naive meet law fails: `gcd a b ∣ F n` is implied by — but not equivalent to — `a ∣ F n`,
so `z(gcd a b)` is **not** `gcd(z a, z b)` in general. The falsifiable conjecture is that
`z(gcd a b) ∣ gcd (z a, z b)` always, with equality exactly when `z a` and `z b` already
form a "saturated" pair. **The key insight is** that the failure of the meet law is
measured entirely by the index-side gcd of the two ranks, so the defect `gcd(z a,z b) /
z(gcd a b)` should be computable from `a, b` alone. **Why now?** With `apparitionRank_lcm`
established, the join half of the lattice morphism is formalized; the meet half is the
only remaining piece needed to decide whether `z` is a full lattice homomorphism, and it
is directly testable by `decide`/`native_decide` on a grid of small `a, b`.

### 2. Closing the Carmichael composite tail via `z(p) = n`

The catalog's `Shared/CarmichaelProof.lean` still carries one `sorry`: composite
`n > 10000` must have a Fibonacci primitive prime divisor. **The key insight is** that
`p` is a primitive divisor of `F n` **iff** `z(p) = n` — a primitive divisor is precisely
a prime whose rank of apparition equals `n` — which converts Carmichael's theorem into the
purely arithmetic statement "every `n > 12` is the rank of apparition of some prime."
**Why now?** The biconditional `fib_dvd_iff_apparitionRank_dvd` plus `apparitionRank_lcm`
let us factor `F n` along the divisor lattice and reduce the existence of a fresh prime to
a counting bound (`F n` is too large to be built only from primes of smaller rank). This
is the most concrete open target in the catalog and is falsifiable: a single composite `n`
with no prime of rank `n` would refute it.

### 3. Wall's "law of repetition" for prime powers

Since `z` is determined on prime powers, the decisive unknown is the jump from `z(p)` to
`z(p^k)`. The conjecture (Wall, 1960) is `z(p^k) = p^{k-1} · z(p)` for all `k ≥ 1`,
failing only at hypothetical **Wall–Sun–Sun primes** (none known below `2^64`). **The key
insight is** that `apparitionRank_dvd_of_dvd` already forces `z(p) ∣ z(p^2) ∣ z(p^3) ∣ …`,
so the entire prime-power ladder is pinned down by the single ratio `z(p^2)/z(p) ∈ {1, p}`.
**Why now?** Our lattice law reduces the conjecture from "all `m`" to "all prime powers,"
and the binary alternative `z(p^2)/z(p) ∈ {1,p}` is exactly a Wall–Sun–Sun test that can be
verified for all `p < N` by `native_decide`, giving an explicit certified range.

### 4. The Pisano period as a bounded multiple of the rank

Let `π(m)` be the Pisano period (period of `F mod m`). The conjecture is
`π(m) / z(m) ∈ {1, 2, 4}` for every `m ≥ 1`. **The key insight is** that both `π` and `z`
are join-controlled by their prime-power values, and the ratio is governed by the order of
`-1` (i.e. of `(-1)^{z(m)}`) in the relevant unit group, which can only contribute a factor
of `1, 2,` or `4`. **Why now?** This cycle gives the first formal handle on `z` as a
multiplicative-lattice object; pairing it with a formalized `π` (also obtainable from the
`fibStep` permutation already defined in `FibApparitionExistence.lean`, whose orbit length
is `π`) makes the ratio a finite, falsifiable invariant checkable modulus by modulus.

### 5. Image and kernel of the rank homomorphism

Because `z` is a monotone join-homomorphism but not injective (`z(1) = z(2)`-type
collisions and rank ties abound), it has a genuine "kernel" structure: the equivalence
`a ∼ b ⟺ z(a) = z(b)`. The conjecture is that each class `{m : z(m) = r}` is finite and
its maximum element is `F r` itself, i.e. `z(m) = r ⟹ m ∣ F r` with `F r` the top. **The
key insight is** that `m ∣ F(z(m))` (which is `apparitionRank_dvd_fib`) already gives the
upper bound `m ∣ F r`, so the only open content is that *every* divisor `m ∣ F r` with no
smaller rank actually attains `z(m) = r`. **Why now?** With monotonicity and the lcm law
proved, the fibers of `z` inherit a lattice structure (closed under `lcm`), so describing
them completely is the natural next theorem and is falsifiable by exhibiting one divisor of
`F r` whose rank is a proper divisor of `r` yet is claimed maximal.
