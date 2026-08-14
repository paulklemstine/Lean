"""Aggregation depth of the free-witness channel, and conversion of a complete witness.

Two routines:

  * `aggregation_depth(N)` returns min{k > 0 : R_k(N) = phi(N)}.  By the completeness
    criterion this equals the Carmichael exponent lambda(N) = lcm_{p | N} phi(p^{v_p(N)})
    for odd N, computed in O(omega(N)) operations after factorisation -- no search needed.
  * `factor_from_complete_witness(N, R)` converts a complete witness R = phi(N) into the
    factorisation in closed form, using (p-1)(q-1) + (p+q) = pq + 1 and one integer square
    root: p, q = (s +- sqrt(s^2 - 4N)) / 2 with s = N + 1 - R.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, Tuple


def factorise(n: int) -> Dict[int, int]:
    """Trial-division factorisation {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def lcm(a: int, b: int) -> int:
    """Least common multiple."""
    return a // gcd(a, b) * b


def totient(n: int) -> int:
    """Euler's totient phi(n)."""
    out = 1
    for p, e in factorise(n).items():
        out *= (p - 1) * p ** (e - 1)
    return out


def aggregation_depth(n: int) -> int:
    """min{k > 0 : R_k(N) = phi(N)} = lambda(N), the Carmichael exponent (odd N)."""
    out = 1
    for p, e in factorise(n).items():
        local = 2 ** (e - 2) if (p == 2 and e >= 3) else (p - 1) * p ** (e - 1)
        out = lcm(out, local)
    return out


def factor_from_complete_witness(n: int, witness: int) -> Tuple[int, int]:
    """Given N = pq and a complete witness R = phi(N), return the ordered pair (p, q)."""
    s = n + 1 - witness                     # = p + q
    disc = s * s - 4 * n
    root = isqrt(disc)
    if root * root != disc:
        raise ValueError("witness is not complete for a semiprime modulus")
    return (s - root) // 2, (s + root) // 2


def depth_report(p: int, q: int) -> str:
    """One line of the aggregation-cost table for the semiprime pq."""
    n = p * q
    phi, dep = totient(n), aggregation_depth(n)
    return (f"N = {n:12d} = {p}*{q}:  phi = {phi:12d},  depth = lambda(N) = {dep:12d}"
            f"  = phi/{gcd(p-1, q-1)},  sqrt(phi) = {isqrt(phi)}")


if __name__ == "__main__":
    for (p, q) in [(11, 13), (61, 67), (10007, 10009), (1000003, 1000033)]:
        print(depth_report(p, q))
    n = 10007 * 10009
    print("complete witness ->", factor_from_complete_witness(n, totient(n)))


"""Construction of joint free-witness profile collisions (the aggregation barrier).

Given a finite exponent set S and a prime q, the algorithm produces arbitrarily many
pairwise distinct semiprimes N = pq carrying byte-for-byte identical joint profiles
(R_k(N))_{k in S}.  Its correctness rests on Dirichlet's theorem: the progression
1 mod lcm(S) contains infinitely many primes, and each such prime saturates every witness
in S (gcd(p-1, k) = k), which erases p from the profile entirely.
"""

from __future__ import annotations

from math import gcd
from typing import List, Sequence, Tuple


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, exact for all 64-bit inputs."""
    if n < 2:
        return False
    bases = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for b in bases:
        if n % b == 0:
            return n == b
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in bases:
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def lcm_list(values: Sequence[int]) -> int:
    """Least common multiple of a list of positive integers."""
    out = 1
    for v in values:
        out = out // gcd(out, v) * v
    return out


def saturating_primes(exponents: Sequence[int], count: int, start: int = 2) -> List[int]:
    """Primes p = 1 mod lcm(S); each satisfies gcd(p-1, k) = k for all k in S."""
    modulus = lcm_list(exponents)
    found: List[int] = []
    candidate = max(start, 1)
    while len(found) < count:
        candidate += 1
        if candidate % modulus == 1 and is_prime(candidate):
            found.append(candidate)
    return found


def profile(p: int, q: int, exponents: Sequence[int]) -> Tuple[int, ...]:
    """The joint S-profile of the semiprime pq, by the trace lemma."""
    return tuple(gcd(k, p - 1) * gcd(k, q - 1) for k in exponents)


def collision_family(
    exponents: Sequence[int], q: int, count: int = 4
) -> Tuple[Tuple[int, ...], List[int]]:
    """Return (common profile, list of primes p) giving `count` colliding semiprimes pq."""
    primes = [p for p in saturating_primes(exponents, count + 1) if p != q][:count]
    profiles = {profile(p, q, exponents) for p in primes}
    assert len(profiles) == 1, "saturating primes must collide"
    return profiles.pop(), primes


if __name__ == "__main__":
    S = [6, 12, 15, 20, 30, 60]
    common, ps = collision_family(S, q=7, count=5)
    print("exponent set:", S, " lcm =", lcm_list(S))
    print("common profile:", common)
    for p in ps:
        print(f"  N = {p}*7 = {p*7:7d}  profile = {profile(p, 7, S)}")
    print("distinct moduli, one profile: no reader of the profile can name p.")


"""The residue/order coordinate: from a nontrivial square root of unity to a factor.

This is the classical post-processing that a quantum order-finding subroutine feeds.  Two
entry points:

  * `crt_sqrt_of_one(p, q)` builds, from a known factorisation, the residue that is 1 mod p
    and -1 mod q -- the explicit witness whose existence the sufficiency theorem asserts.
  * `factor_from_order(N, a, r)` performs the standard reduction: given the multiplicative
    order r of a unit a modulo N, if r is even and a^{r/2} is not -1 modulo N, then
    gcd(a^{r/2} - 1, N) is a nontrivial divisor.  `factor_by_order_search(N)` runs the whole
    loop classically (order finding by brute force, which is exactly the step whose cost the
    aggregation barrier quantifies and the quantum Fourier transform removes).

Complexity: the post-processing is O(log N) multiplications plus one gcd.  The search for a
usable order is the expensive part -- Theta(lambda(N)) classically, one coherent evaluation
quantumly.
"""

from __future__ import annotations

from math import gcd
from typing import Optional, Tuple


def crt_sqrt_of_one(p: int, q: int) -> int:
    """The residue a with a = 1 (mod p), a = -1 (mod q); satisfies a^2 = 1, a != +-1."""
    n = p * q
    inv = pow(q, -1, p)
    a = (-1 + 2 * q * inv) % n
    assert pow(a, 2, n) == 1 and a not in (1, n - 1)
    return a


def multiplicative_order(a: int, n: int) -> int:
    """Least r > 0 with a^r = 1 mod n, by brute force (the classically expensive step)."""
    if gcd(a, n) != 1:
        raise ValueError("a must be a unit modulo n")
    r, x = 1, a % n
    while x != 1:
        x = x * a % n
        r += 1
    return r


def factor_from_order(n: int, a: int, r: int) -> Optional[Tuple[int, int]]:
    """Post-processing: turn an even order with a nontrivial half-power into a splitting."""
    if r % 2 != 0:
        return None
    h = pow(a, r // 2, n)
    if h == n - 1 or h == 1:
        return None
    g = gcd(h - 1, n)
    if 1 < g < n:
        return g, n // g
    return None


def factor_by_order_search(n: int, max_tries: int = 50) -> Optional[Tuple[int, int]]:
    """Full classical order-finding factorisation loop (Shor's algorithm minus the quantum)."""
    for a in range(2, 2 + max_tries):
        g = gcd(a, n)
        if 1 < g < n:
            return g, n // g
        if g != 1:
            continue
        r = multiplicative_order(a, n)
        split = factor_from_order(n, a, r)
        if split is not None:
            return split
    return None


if __name__ == "__main__":
    n = 83 * 97
    a = crt_sqrt_of_one(83, 97)
    print(f"explicit witness a = {a}: a^2 mod {n} = {pow(a, 2, n)}, gcd(a-1, N) = {gcd(a-1, n)}")
    print("order-finding loop on 8051 ->", factor_by_order_search(8051))
    print("order-finding loop on 100160063 ->", factor_by_order_search(100160063, max_tries=5))


"""Free-witness evaluation via the trace lemma, with a brute-force cross-check.

R_k(N) = #{x in (Z/N)^* : x^k = 1}.  For every odd N (and any N with at most four dividing
the modulus) the trace lemma evaluates this in O(omega(N)) gcd operations once the
factorisation is known, versus Theta(N log k) for the definition.
"""

from __future__ import annotations

from math import gcd
from typing import Dict


def factorise(n: int) -> Dict[int, int]:
    """Trial-division factorisation {prime: exponent}.  O(sqrt(n)) time."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def local_totient(p: int, e: int) -> int:
    """phi(p^e) = (p-1) p^{e-1}: the order of the local unit group at an odd prime."""
    return (p - 1) * p ** (e - 1)


def free_witness(n: int, k: int) -> int:
    """R_k(N) by the trace lemma: prod_{p | N} gcd(phi(p^{v_p(N)}), k).

    Exact for odd N.  For N = pq a semiprime this is gcd(k, p-1) * gcd(k, q-1).
    Complexity: one factorisation plus omega(N) gcds.
    """
    out = 1
    for p, e in factorise(n).items():
        out *= gcd(local_totient(p, e), k)
    return out


def free_witness_bruteforce(n: int, k: int) -> int:
    """R_k(N) directly from the definition.  Theta(N log k) time -- reference only."""
    return sum(1 for x in range(1, n) if gcd(x, n) == 1 and pow(x, k, n) == 1)


def verify(limit_n: int = 200, limit_k: int = 12) -> int:
    """Cross-check the closed formula against brute force for all odd N < limit_n."""
    checked = 0
    for n in range(3, limit_n, 2):
        for k in range(1, limit_k + 1):
            assert free_witness(n, k) == free_witness_bruteforce(n, k), (n, k)
            checked += 1
    return checked


if __name__ == "__main__":
    print("checked", verify(), "instances of the trace lemma; all agree")
    print("R_6(3*7)  =", free_witness(21, 6), " (= gcd(6,2)*gcd(6,6) = 2*6)")
    print("R_2(3*5*7)=", free_witness(105, 2), " (= 2^omega = 8)")


"""The cost of aggregation, measured: exponent sweep versus one residue witness.

For a sequence of semiprimes this demo measures three quantities directly:

  * the number of exponents k = 1, 2, 3, ... that must be swept before some free witness
    R_k(N) becomes complete (equal to phi(N)) -- the classical aggregation depth;
  * how far below completeness the whole swept profile stays, illustrating that partial
    witnesses never accumulate into a complete one;
  * the work done by the residue/order coordinate: one square root of unity, one gcd.

The gap between the two columns is the entire quantum advantage in factoring.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, List, Tuple


def factorise(n: int) -> Dict[int, int]:
    """Trial-division factorisation {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def totient(n: int) -> int:
    """Euler's totient."""
    out = 1
    for p, e in factorise(n).items():
        out *= (p - 1) * p ** (e - 1)
    return out


def free_witness(p: int, q: int, k: int) -> int:
    """Trace lemma for a semiprime: R_k(pq) = gcd(k, p-1) gcd(k, q-1)."""
    return gcd(k, p - 1) * gcd(k, q - 1)


def sweep_until_complete(p: int, q: int, cap: int = 10 ** 7) -> Tuple[int, int]:
    """Return (least complete exponent found, best witness value seen), sweeping k upward."""
    phi = (p - 1) * (q - 1)
    best = 0
    for k in range(1, cap + 1):
        r = free_witness(p, q, k)
        best = max(best, r)
        if r == phi:
            return k, r
    return 0, best


def residue_witness_cost(p: int, q: int) -> Tuple[int, int]:
    """Build the nontrivial square root of unity and split N; return (witness, factor)."""
    n = p * q
    a = (-1 + 2 * q * pow(q, -1, p)) % n
    return a, gcd(a - 1, n)


def race(pairs: List[Tuple[int, int]]) -> None:
    """Print the aggregation race table for a list of prime pairs."""
    header = (f"{'N':>14} {'phi(N)':>14} {'sweep depth':>12} {'sqrt(phi)':>10} "
              f"{'depth/sqrt':>10} {'residue work':>13}")
    print(header)
    print("-" * len(header))
    for (p, q) in pairs:
        n = p * q
        depth, _ = sweep_until_complete(p, q)
        phi = totient(n)
        _, factor = residue_witness_cost(p, q)
        assert n % factor == 0 and 1 < factor < n
        print(f"{n:>14} {phi:>14} {depth:>12} {isqrt(phi):>10} "
              f"{depth / max(isqrt(phi), 1):>10.2f} {'1 gcd -> ' + str(factor):>13}")


if __name__ == "__main__":
    print(__doc__)
    race([(3, 5), (5, 7), (11, 13), (23, 29), (61, 67), (101, 103), (211, 223), (521, 523)])
    print()
    print("The sweep depth grows like phi(N)/gcd(p-1,q-1) -- linear in N, exponential in")
    print("log N -- while the residue coordinate costs one gcd at every size.")


"""Aggregation depth versus modulus size, on log-log axes.

For every semiprime N = pq below a bound, plot the least exponent k with R_k(N) = phi(N) --
proved to equal lcm(p-1, q-1) = phi(N)/gcd(p-1, q-1).  Reference curves sqrt(N) and N/2 show
that the depth tracks N, not sqrt(N): the crude divisibility bound R_k(N) | k^2 is far from
sharp, and the true classical aggregation cost is linear in the modulus.

Run:  python3 viz_aggregation_depth.py   (writes aggregation_depth.png)
"""

from __future__ import annotations

from math import gcd
from typing import List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = np.ones(n + 1, dtype=bool)
    sieve[:2] = False
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = False
    return [int(i) for i in np.nonzero(sieve)[0]]


def depths(limit: int) -> Tuple[List[int], List[int], List[int]]:
    """Return (moduli, depths, gcd(p-1,q-1)) for odd semiprimes N = pq < limit."""
    ps = [p for p in primes_up_to(int(limit ** 0.5) + 200) if p > 2]
    xs, ys, gs = [], [], []
    for i, p in enumerate(ps):
        for q in ps[i + 1:]:
            n = p * q
            if n > limit:
                break
            g = gcd(p - 1, q - 1)
            xs.append(n)
            ys.append((p - 1) * (q - 1) // g)
            gs.append(g)
    return xs, ys, gs


def main() -> None:
    xs, ys, gs = depths(2_000_000)
    fig, ax = plt.subplots(figsize=(11, 7))
    sc = ax.scatter(xs, ys, c=np.log2(gs), s=6, cmap="viridis", alpha=0.65)
    grid = np.logspace(1, np.log10(max(xs)), 200)
    ax.plot(grid, np.sqrt(grid), "r--", lw=2, label=r"$\sqrt{N}$  (crude bound $R_k\mid k^2$)")
    ax.plot(grid, grid / 2, "w-", lw=2, label=r"$N/2$  (typical depth, $\gcd(p-1,q-1)=2$)")
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel("modulus $N = pq$", fontsize=12)
    ax.set_ylabel(r"aggregation depth $\min\{k>0: R_k(N)=\varphi(N)\}$", fontsize=12)
    ax.set_title("The free-witness channel closes only at exponent depth $\\lambda(N)$",
                 fontsize=13)
    cbar = fig.colorbar(sc, ax=ax)
    cbar.set_label(r"$\log_2 \gcd(p-1,q-1)$")
    ax.legend(loc="upper left")
    ax.grid(alpha=0.25, which="both")
    fig.tight_layout()
    fig.savefig("aggregation_depth.png", dpi=160)
    print("wrote aggregation_depth.png  (", len(xs), "semiprimes )")


if __name__ == "__main__":
    main()


"""The collision picture: many distinct moduli, one joint free-witness profile.

Left panel: the joint profiles (R_k(N))_{k in S} of several semiprimes N = pq with q fixed
and p running over the primes congruent to 1 modulo lcm(S) -- the bars coincide exactly,
which is the aggregation barrier in one image.  Right panel: for contrast, the profiles of
non-saturating primes, which do differ but still fail to determine p, since each one is
matched by infinitely many other primes in its own congruence class.

Run:  python3 viz_profile_collision.py   (writes profile_collision.png)
"""

from __future__ import annotations

from math import gcd
from typing import List, Sequence

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def is_prime(n: int) -> bool:
    """Simple deterministic primality test for small inputs."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def lcm_list(values: Sequence[int]) -> int:
    """Least common multiple of a list."""
    out = 1
    for v in values:
        out = out // gcd(out, v) * v
    return out


def profile(p: int, q: int, S: Sequence[int]) -> List[int]:
    """Joint free-witness profile of pq over the exponent set S."""
    return [gcd(k, p - 1) * gcd(k, q - 1) for k in S]


def main() -> None:
    S = [6, 12, 15, 20, 30, 60]
    q = 7
    M = lcm_list(S)
    saturating = [p for p in range(M + 1, 4000) if p % M == 1 and is_prime(p)][:5]
    others = [p for p in range(11, 200) if is_prime(p) and p % M != 1][:5]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5.5), sharey=True)
    width = 0.15
    idx = np.arange(len(S))

    for j, p in enumerate(saturating):
        axes[0].bar(idx + j * width, profile(p, q, S), width, label=f"N = {p}·{q}")
    axes[0].set_title(f"Saturating primes $p \\equiv 1$ (mod {M}): identical profiles",
                      fontsize=12)

    for j, p in enumerate(others):
        axes[1].bar(idx + j * width, profile(p, q, S), width, label=f"N = {p}·{q}")
    axes[1].set_title("Generic primes: profiles differ, yet each still has\n"
                      "infinitely many colliding partners", fontsize=12)

    for ax in axes:
        ax.set_xticks(idx + 2 * width)
        ax.set_xticklabels([f"$k={k}$" for k in S])
        ax.set_ylabel(r"$R_k(N)$")
        ax.legend(fontsize=8)
        ax.grid(axis="y", alpha=0.25)

    fig.suptitle("Joint free-witness profiles over $S=\\{6,12,15,20,30,60\\}$, $q=7$",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("profile_collision.png", dpi=160)
    print("wrote profile_collision.png")


if __name__ == "__main__":
    main()


"""Heatmap of the free-witness family R_k(N) = gcd(k, p-1) gcd(k, q-1).

Rows are semiprimes N = pq, columns are exponents k, and the colour is the *fraction of
completeness* R_k(N) / phi(N).  The picture makes the two theorems visible at once: the
grid is bright only on the sparse lattice of multiples of lcm(p-1, q-1) (the aggregation
depth), and everywhere else the witnesses are small -- no amount of joining the dim cells
produces a bright one.

Run:  python3 viz_witness_heatmap.py   (writes witness_heatmap.png)
"""

from __future__ import annotations

from math import gcd
from typing import List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def free_witness(p: int, q: int, k: int) -> int:
    """Trace lemma for a semiprime."""
    return gcd(k, p - 1) * gcd(k, q - 1)


def build_grid(pairs: List[Tuple[int, int]], kmax: int) -> np.ndarray:
    """Matrix of completeness fractions R_k(N)/phi(N)."""
    grid = np.zeros((len(pairs), kmax))
    for i, (p, q) in enumerate(pairs):
        phi = (p - 1) * (q - 1)
        for k in range(1, kmax + 1):
            grid[i, k - 1] = free_witness(p, q, k) / phi
    return grid


def main() -> None:
    pairs = [(3, 5), (3, 7), (5, 7), (5, 11), (7, 11), (7, 13), (11, 13), (11, 17),
             (13, 17), (13, 19), (17, 19), (19, 23)]
    kmax = 120
    grid = build_grid(pairs, kmax)

    fig, ax = plt.subplots(figsize=(13, 6))
    im = ax.imshow(grid, aspect="auto", origin="lower", cmap="magma",
                   extent=(0.5, kmax + 0.5, -0.5, len(pairs) - 0.5), vmin=0, vmax=1)
    ax.set_yticks(range(len(pairs)))
    ax.set_yticklabels([f"{p*q} = {p}·{q}" for (p, q) in pairs], fontsize=9)
    ax.set_xlabel("exponent $k$", fontsize=12)
    ax.set_title(r"Completeness fraction $R_k(N)/\varphi(N)$ for $R_k(N)=\gcd(k,p-1)\gcd(k,q-1)$",
                 fontsize=13)
    cbar = fig.colorbar(im, ax=ax)
    cbar.set_label(r"$R_k(N)/\varphi(N)$  (1 = complete)")

    # mark the aggregation depth lcm(p-1, q-1) of each row
    for i, (p, q) in enumerate(pairs):
        depth = (p - 1) * (q - 1) // gcd(p - 1, q - 1)
        if depth <= kmax:
            ax.plot([depth], [i], marker="o", markersize=6, markerfacecolor="none",
                    markeredgecolor="cyan", markeredgewidth=1.6)
    ax.plot([], [], marker="o", markersize=6, markerfacecolor="none", markeredgecolor="cyan",
            linestyle="none", label=r"aggregation depth $\lambda(N)=\mathrm{lcm}(p-1,q-1)$")
    ax.legend(loc="upper left", facecolor="white", framealpha=0.85)

    fig.tight_layout()
    fig.savefig("witness_heatmap.png", dpi=160)
    print("wrote witness_heatmap.png")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the deliverables and assets in this directory."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "_assets"

LEAN_FILES = [
    "Catalog/Geometry/Round10Closures.lean",
    "Catalog/Geometry/Round10Closures/TraceLemma.lean",
    "Catalog/Geometry/Round10Closures/JointClosure.lean",
    "Catalog/Geometry/Round10Closures/RainbowWalk.lean",
    "Catalog/Geometry/Round10Closures/QuantumBypass.lean",
    "Catalog/Geometry/Round10Closures/HintAmplification.lean",
    "Catalog/Geometry/Round10Closures/Synthesis.lean",
    "Catalog/Geometry/Round10Closures/AggregationCost.lean",
    "Catalog/Geometry/Round10Closures/SquarefreeTrace.lean",
    "Catalog/Geometry/Round10Closures/CarmichaelThreshold.lean",
]


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def asset(name: str) -> str:
    return (ASSETS / name).read_text(encoding="utf-8")


algorithms = [
    {
        "name": "Trace-Lemma Evaluation of the Free-Witness Family",
        "description": (
            "Evaluates R_k(N) = #{x mod N : gcd(x,N)=1, x^k = 1}, the number of k-th roots of "
            "unity modulo N. The naive definition costs Theta(N log k) modular operations; the "
            "trace lemma reduces this to one factorisation plus omega(N) greatest-common-divisor "
            "computations, since R_k(N) = prod over primes p | N of gcd(phi(p^{v_p(N)}), k) — "
            "equal to gcd(k, p-1)·gcd(k, q-1) for a semiprime N = pq. The derivation is the "
            "Chinese remainder theorem (which splits the unit group into local factors), "
            "multiplicativity of root counts over direct products, and the cyclic root count "
            "(x^k = 1 has exactly gcd(n,k) solutions in a cyclic group of order n). The routine "
            "also ships a brute-force reference implementation and a cross-checking harness that "
            "verifies the two against each other for all odd moduli below a bound; every check "
            "passes. The formula is exact for odd N and for N with at most four dividing it — the "
            "2-adic case with 8 | N is the one open exception, since the local unit group is then "
            "not cyclic."
        ),
        "pseudocode": (
            "INPUT:  modulus N >= 1 (odd), exponent k >= 0\n"
            "OUTPUT: R_k(N), the number of k-th roots of unity in (Z/N)^*\n"
            "\n"
            "1. Factor N = prod_i p_i^{e_i}                      # O(sqrt N) by trial division\n"
            "2. result <- 1\n"
            "3. FOR each prime power p^e || N DO\n"
            "4.     local <- (p - 1) * p^{e-1}                   # phi(p^e), order of the local\n"
            "                                                    #   unit group (cyclic, p odd)\n"
            "5.     result <- result * gcd(local, k)             # cyclic root count\n"
            "6. RETURN result\n"
            "\n"
            "REFERENCE (definition, for validation only):\n"
            "1. count <- 0\n"
            "2. FOR x = 1 TO N-1 DO\n"
            "3.     IF gcd(x, N) = 1 AND x^k mod N = 1 THEN count <- count + 1\n"
            "4. RETURN count                                     # Theta(N log k)\n"
        ),
        "code": asset("alg_trace_lemma.py"),
    },
    {
        "name": "Dirichlet Construction of Joint Free-Witness Profile Collisions",
        "description": (
            "Constructs, for any finite exponent set S and any prime q, arbitrarily many pairwise "
            "distinct semiprimes N = pq whose joint free-witness profiles (R_k(N))_{k in S} are "
            "byte-for-byte identical. The construction is the algorithmic content of the "
            "aggregation barrier. It searches the arithmetic progression 1 mod lcm(S), which by "
            "Dirichlet's theorem contains infinitely many primes; each such prime p saturates every "
            "witness (gcd(p-1,k) = k for all k in S), so by the trace lemma the profile collapses "
            "to k -> k·gcd(q-1,k), a quantity in which p does not appear at all. Cost: a Miller-"
            "Rabin scan of the progression, expected O(lcm(S) · log^3 N) bit operations per prime "
            "found by the prime number theorem for arithmetic progressions. The consequence is "
            "information-theoretic rather than computational: since two distinct moduli present a "
            "profile-reading algorithm with equal inputs, no such algorithm — of any running time — "
            "can name a prime factor."
        ),
        "pseudocode": (
            "INPUT:  finite exponent set S of positive integers, prime q, count m\n"
            "OUTPUT: m distinct primes p, all giving semiprimes pq with one common S-profile\n"
            "\n"
            "1. M <- lcm(S)                                      # the saturating modulus\n"
            "2. found <- empty list; candidate <- M + 1\n"
            "3. WHILE |found| < m DO\n"
            "4.     IF candidate = 1 (mod M) AND MillerRabin(candidate) AND candidate != q THEN\n"
            "5.         append candidate to found\n"
            "6.     candidate <- candidate + 1\n"
            "7. FOR each p in found DO                           # verification\n"
            "8.     profile(p) <- ( gcd(k, p-1) * gcd(k, q-1) : k in S )\n"
            "9. ASSERT all profiles are equal, and equal to ( k * gcd(k, q-1) : k in S )\n"
            "10. RETURN found, common profile\n"
        ),
        "code": asset("alg_profile_collision.py"),
    },
    {
        "name": "Computation of the Aggregation Depth and Closed-Form Inversion of a Complete Witness",
        "description": (
            "Two coupled routines that quantify the aggregation barrier and then discharge it. The "
            "first computes the aggregation depth of a modulus — the least exponent k > 0 with "
            "R_k(N) = phi(N) — which the completeness criterion identifies with the Carmichael "
            "exponent lambda(N) = lcm over primes p | N of phi(p^{v_p(N)}); no search is needed, "
            "only omega(N) least-common-multiple operations after factorisation. For a semiprime "
            "this is lcm(p-1, q-1) = phi(N)/gcd(p-1, q-1), of order N for cryptographic primes and "
            "hence exponential in log N. The second routine converts a complete witness into the "
            "factorisation in closed form: the identity (p-1)(q-1) + (p+q) = pq + 1 turns the "
            "witness into the trace s = N + 1 - phi(N), and then p, q = (s +- sqrt(s^2 - 4N))/2, "
            "computed exactly with an integer square root in O(log N) bit operations. Together the "
            "two routines exhibit the dichotomy: the classical channel is complete, but only at "
            "exponential exponent depth."
        ),
        "pseudocode": (
            "AGGREGATION DEPTH\n"
            "INPUT:  odd modulus N >= 3\n"
            "OUTPUT: min{ k > 0 : R_k(N) = phi(N) }\n"
            "1. Factor N = prod p_i^{e_i}\n"
            "2. depth <- 1\n"
            "3. FOR each prime power p^e || N DO\n"
            "4.     local <- 2^{e-2}       IF p = 2 AND e >= 3\n"
            "                (p-1)p^{e-1}  OTHERWISE\n"
            "5.     depth <- lcm(depth, local)\n"
            "6. RETURN depth                                     # = lambda(N)\n"
            "\n"
            "CLOSED-FORM INVERSION OF A COMPLETE WITNESS\n"
            "INPUT:  semiprime N, a witness value R with R = phi(N)\n"
            "OUTPUT: the ordered factor pair (p, q)\n"
            "1. s <- N + 1 - R                                   # = p + q, by the identity\n"
            "2. D <- s*s - 4*N\n"
            "3. r <- isqrt(D);  ASSERT r*r = D                   # else R was not complete\n"
            "4. RETURN ( (s - r)/2, (s + r)/2 )\n"
        ),
        "code": asset("alg_aggregation_depth.py"),
    },
    {
        "name": "Residue-Witness Post-Processing: From a Square Root of Unity to a Prime Factor",
        "description": (
            "The classical post-processing that a quantum order-finding subroutine feeds, isolated "
            "and implemented on its own. Given a unit a modulo N of even multiplicative order r "
            "with a^{r/2} not congruent to -1, the greatest common divisor gcd(a^{r/2} - 1, N) is a "
            "nontrivial divisor: N divides (a^{r/2}-1)(a^{r/2}+1) while dividing neither factor, so "
            "the two primes are separated between them. The module also constructs the witness "
            "explicitly from a known factorisation — the Chinese-remainder residue that is 1 modulo "
            "p and -1 modulo q — demonstrating unconditionally that such a witness always exists "
            "for a semiprime built from distinct odd primes, and that by the trace lemma exactly "
            "two of the four square roots of unity are useful, a 50% target. The post-processing "
            "costs O(log N) modular multiplications plus one gcd; the expensive part is locating a "
            "usable order, which is Theta(lambda(N)) classically by brute-force search (included "
            "here) and a single coherent evaluation quantumly. That asymmetry, and nothing else, is "
            "the quantum advantage in factoring."
        ),
        "pseudocode": (
            "EXPLICIT WITNESS (factorisation known; existence proof made constructive)\n"
            "INPUT:  distinct odd primes p, q\n"
            "OUTPUT: a with a^2 = 1 mod pq, a != +-1\n"
            "1. inv <- q^{-1} mod p\n"
            "2. a <- (-1 + 2*q*inv) mod pq                       # a = 1 (mod p), a = -1 (mod q)\n"
            "3. ASSERT a^2 = 1 mod pq AND a not in {1, pq-1}\n"
            "4. RETURN a\n"
            "\n"
            "ORDER-BASED FACTORISATION (the loop whose search step Shor's algorithm replaces)\n"
            "INPUT:  odd composite N\n"
            "OUTPUT: a nontrivial factor pair, or FAIL\n"
            "1. FOR a = 2, 3, 4, ... DO\n"
            "2.     g <- gcd(a, N);  IF 1 < g < N THEN RETURN (g, N/g)\n"
            "3.     r <- multiplicative order of a modulo N      # Theta(lambda(N)) classically\n"
            "4.     IF r is odd THEN CONTINUE\n"
            "5.     h <- a^{r/2} mod N\n"
            "6.     IF h = 1 OR h = N-1 THEN CONTINUE            # useless square root\n"
            "7.     g <- gcd(h - 1, N)\n"
            "8.     IF 1 < g < N THEN RETURN (g, N/g)\n"
            "9. RETURN FAIL\n"
        ),
        "code": asset("alg_residue_factor.py"),
    },
]

demos = [
    {
        "name": "Complete Numerical Verification of the Free-Witness Theory",
        "description": (
            "A single self-contained script that exercises every result in the development and "
            "asserts each displayed value against the theory. It (1) cross-checks brute-force "
            "counts of k-th roots of unity against the trace lemma for semiprimes, squarefree and "
            "odd prime-power moduli; (2) verifies the information budget R_k(N) | k^2; (3) "
            "constructs explicit joint-profile collisions from Dirichlet saturating primes, showing "
            "several distinct semiprimes with literally identical profiles; (4) confirms by "
            "exhaustive search that the least complete exponent equals lcm(p-1,q-1) = lambda(N), "
            "and compares it with the crude bound sqrt(phi(N)); (5) converts a complete witness "
            "into the factorisation in closed form; (6) demonstrates that the multiplicative "
            "smooth-step walk visits only units, so its gcd channel is identically trivial, and "
            "measures its period against the order of the step; (7) builds the nontrivial square "
            "root of unity and splits N with a single gcd, tabulating the population 2^omega(N) of "
            "the coordinate; and (8) amplifies the additive hint p+q to the factorisation. Every "
            "assertion passes; standard library only."
        ),
        "code": read("demo.py"),
    },
    {
        "name": "The Aggregation Race: Measured Sweep Depth versus One Residue Witness",
        "description": (
            "A head-to-head measurement of the two costs the theory separates. For a sequence of "
            "semiprimes the script sweeps exponents k = 1, 2, 3, ... and records how many must be "
            "examined before some free witness becomes complete (equal to phi(N)) — the classical "
            "aggregation depth — while tracking the running maximum witness to show that partial "
            "witnesses never accumulate into a complete one. Against this it prices the residue "
            "coordinate: one Chinese-remainder square root of unity and one greatest common "
            "divisor, at every modulus size. The resulting table shows the sweep depth growing like "
            "phi(N)/gcd(p-1,q-1), i.e. linearly in N and exponentially in log N, against a constant "
            "cost on the other side; the ratio column makes the divergence explicit. That gap, and "
            "nothing else, is what a quantum order-finding step removes."
        ),
        "code": asset("demo_aggregation_race.py"),
    },
]

visualizations = [
    {
        "name": "Completeness Heatmap of the Free-Witness Family",
        "description": (
            "A heatmap whose rows are semiprimes N = pq, whose columns are exponents k, and whose "
            "colour is the completeness fraction R_k(N)/phi(N) = gcd(k,p-1)gcd(k,q-1)/((p-1)(q-1)). "
            "Two theorems become visible at once: the grid is bright only on the sparse lattice of "
            "multiples of lcm(p-1,q-1) — the aggregation depth, marked with a ring on each row — "
            "and everywhere else the witnesses are dim, no matter how many of them you take "
            "together. Requires matplotlib and numpy; writes witness_heatmap.png."
        ),
        "code": asset("viz_witness_heatmap.py"),
    },
    {
        "name": "Aggregation Depth versus Modulus Size (log-log)",
        "description": (
            "For every odd semiprime N = pq below two million, the least exponent k with "
            "R_k(N) = phi(N) — proved to equal lcm(p-1,q-1) = phi(N)/gcd(p-1,q-1) — plotted against "
            "N on log-log axes and coloured by log2 gcd(p-1,q-1). Reference curves sqrt(N) and N/2 "
            "show that the depth tracks N rather than sqrt(N): the crude divisibility bound "
            "R_k(N) | k^2 is true but far from sharp, and the true classical aggregation cost is "
            "linear in the modulus. Requires matplotlib and numpy; writes aggregation_depth.png."
        ),
        "code": asset("viz_aggregation_depth.py"),
    },
    {
        "name": "Profile Collisions: Distinct Moduli, One Joint Witness Vector",
        "description": (
            "A two-panel bar chart of joint free-witness profiles over the exponent set "
            "{6,12,15,20,30,60} with the prime q = 7 held fixed. The left panel shows semiprimes "
            "built from Dirichlet saturating primes (p congruent to 1 modulo 60): the bars coincide "
            "exactly, so five different moduli present one and the same data to any profile-reading "
            "algorithm. The right panel shows generic primes, whose profiles differ but which are "
            "each matched by infinitely many other primes in their own congruence class. Requires "
            "matplotlib and numpy; writes profile_collision.png."
        ),
        "code": asset("viz_profile_collision.py"),
    },
]

interactive_demos = [
    {
        "title": "The Free-Witness Explorer — count roots of unity and watch the formula hold",
        "description": (
            "A three-panel laboratory for the whole theory. Panel one lets you choose two primes and "
            "an exponent and computes the number of k-th roots of unity modulo N = pq twice — by "
            "brute force over all residues, and by the closed formula gcd(k,p-1)·gcd(k,q-1) — "
            "displaying the agreement, the completeness fraction R_k/phi(N), and a live bar strip of "
            "the whole family over k = 1..240 with the aggregation depth lcm(p-1,q-1) highlighted in "
            "amber. Panel two is the aggregation barrier made tangible: pick an exponent set and a "
            "fixed prime q and the widget finds Dirichlet saturating primes and tabulates their "
            "joint profiles, which coincide row for row. Panel three exhibits the bypass: it lists "
            "all four square roots of unity, builds the Chinese-remainder witness that is 1 modulo p "
            "and -1 modulo q, and splits N with a single greatest common divisor, alongside the "
            "closed-form amplification of the hint p+q. Pure HTML, CSS and JavaScript; no "
            "dependencies."
        ),
        "html": asset("widget_explorer.html"),
    },
    {
        "title": "The Aggregation Race — classical sweep versus one coherent shot",
        "description": (
            "An animated side-by-side simulation of the two channels. The left lane runs the "
            "classical aggregation: it sweeps exponents k = 1, 2, 3, ... in real time, plotting the "
            "running maximum of R_k(N)/phi(N) and reporting how many exponents have been examined, "
            "and it can only finish at k = lcm(p-1,q-1). The right lane performs the one-shot read "
            "of the residue/order coordinate: a nontrivial square root of unity, one greatest common "
            "divisor, done. A live chart overlays the classical curve against the flat quantum "
            "success line, and on completion the verdict panel reports the exact ratio of the two "
            "costs. Two progressive-disclosure sections give the full arguments — why the classical "
            "lane cannot finish early (the completeness criterion plus the Dirichlet collision), and "
            "why the right-hand lane finishes immediately (the square-root splitting argument). Pure "
            "HTML, CSS and JavaScript; no dependencies."
        ),
        "html": asset("widget_race.html"),
    },
]

lean_proofs = "\n\n".join(f"-- ===== {f} =====\n{read(f)}" for f in LEAN_FILES)

package = {
    "title": "Free Witnesses, Aggregation Depth, and the Localisation of the Quantum "
             "Advantage in Integer Factorisation",
    "domain": "Geometry",
    "description": (
        "A complete classification of the free-witness family R_k(N), the number of k-th roots of "
        "unity modulo N — equal to gcd(k,p-1)gcd(k,q-1) for a semiprime and to the product of local "
        "gcd-residue coordinates for every odd modulus — together with an information-theoretic "
        "proof that no finite aggregation of these invariants can name a prime factor, an exact "
        "aggregation depth equal to the Carmichael exponent, and the resulting localisation of the "
        "quantum factoring advantage at the aggregation step rather than at the classification."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-14",
    "key_results": [
        "Trace lemma: for a semiprime N = pq the number of k-th roots of unity modulo N is exactly "
        "gcd(k, p-1)·gcd(k, q-1); for every odd modulus it is the product over primes p dividing N "
        "of gcd(phi(p^{v_p(N)}), k), and for an odd squarefree modulus the square roots of unity "
        "number exactly 2^omega(N).",
        "Joint-closure theorem: for every finite exponent set S and every prime q there are "
        "infinitely many primes p whose semiprimes pq share one joint free-witness profile over S, "
        "so no function of the profile returns a prime factor — an information-theoretic barrier, "
        "not merely a computational one.",
        "Exact aggregation depth: the free witness attains its maximum phi(N) precisely at the "
        "multiples of the Carmichael exponent, so the least complete exponent is "
        "lcm(p-1, q-1) = phi(N)/gcd(p-1, q-1) for a semiprime and lcm of the local totients for "
        "every odd modulus — exponential in log N — while the divisibility bound R_k(N) | k^2 "
        "already forces k at least the square root of phi(N).",
        "Residue-witness sufficiency and quantum localisation: for N = pq with distinct odd primes "
        "there are exactly four square roots of unity, and each of the two nontrivial ones splits N "
        "through a single greatest common divisor, so the quantum speedup bypasses the aggregation "
        "cost rather than the classification of witnesses.",
        "Walk sterility and hint pricing: the multiplicative smooth-step walk visits only units, so "
        "its greatest-common-divisor channel is identically trivial and its orbit is a coset of the "
        "subgroup generated by the step, while the single external hint p+q amplifies to the "
        "factorisation in closed form via p = (s − sqrt(s² − 4N))/2 and determines the ordered "
        "factor pair uniquely.",
    ],
    "keywords": [
        "integer factorisation",
        "roots of unity",
        "Carmichael function",
        "Dirichlet's theorem",
        "Chinese remainder theorem",
        "order finding",
        "aggregation barrier",
        "cryptographic hardness",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": demos,
    "algorithms": algorithms,
    "visualizations": visualizations,
    "interactive_demos": interactive_demos,
    "interactive_layout": asset("layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": asset("future_directions.md"),
    "modules": {"demo": read("demo.py")},
    "lean_files": LEAN_FILES,
}

(ROOT / "PACKAGE.json").write_text(
    json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8"
)
print("PACKAGE.json written:", (ROOT / "PACKAGE.json").stat().st_size, "bytes")


"""
Free witnesses, aggregation depth, and the localisation of the quantum advantage.

Numerical demonstrations of the results:

  1. Trace lemma          R_k(pq) = gcd(k, p-1) * gcd(k, q-1)          (brute force check)
  2. Squarefree / odd     R_k(N)  = prod_p gcd(phi(p^v_p(N)), k)
  3. Information budget   R_k(pq) | k^2
  4. Joint closure        distinct semiprimes with identical S-profiles (Dirichlet)
  5. Aggregation depth    min{k > 0 : R_k(N) = phi(N)} = lcm(p-1, q-1) = lambda(N)
  6. Complete witness     Phi(N, N + 1 - phi(N)) = smaller prime factor
  7. Walk sterility       x -> x*s mod N never emits a nontrivial gcd
  8. Residue witness      a^2 = 1, a != +-1  =>  gcd(a-1, N) is a prime factor
  9. Hint amplification   Phi(N, p+q) = p

Self-contained: standard library only.  Run with `python3 demo.py`.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, Iterable, List, Sequence, Tuple


# --------------------------------------------------------------------------------------
# Elementary number theory helpers
# --------------------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for 64-bit inputs (exact for n < 3.3 * 10^24)."""
    if n < 2:
        return False
    small_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for p in small_primes:
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in small_primes:
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def lcm(a: int, b: int) -> int:
    """Least common multiple of two positive integers."""
    return a // gcd(a, b) * b


def lcm_list(values: Iterable[int]) -> int:
    """Least common multiple of a list of positive integers (empty list -> 1)."""
    out = 1
    for v in values:
        out = lcm(out, v)
    return out


def factorise(n: int) -> Dict[int, int]:
    """Trial-division factorisation, returning {prime: exponent}.  Fine for demo sizes."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def totient(n: int) -> int:
    """Euler's totient phi(n)."""
    out = 1
    for p, e in factorise(n).items():
        out *= (p - 1) * p ** (e - 1)
    return out


def carmichael(n: int) -> int:
    """Carmichael exponent lambda(n): the exponent of the unit group modulo n."""
    parts: List[int] = []
    for p, e in factorise(n).items():
        if p == 2 and e >= 3:
            parts.append(2 ** (e - 2))
        else:
            parts.append((p - 1) * p ** (e - 1))
    return lcm_list(parts)


# --------------------------------------------------------------------------------------
# 1-3.  Free witnesses and the trace lemma
# --------------------------------------------------------------------------------------

def free_witness_bruteforce(n: int, k: int) -> int:
    """R_k(N) computed by definition: #{x mod N : gcd(x,N)=1 and x^k = 1 mod N}."""
    return sum(1 for x in range(1, n) if gcd(x, n) == 1 and pow(x, k, n) == 1)


def free_witness_formula(n: int, k: int) -> int:
    """R_k(N) from the trace lemma: prod over p | N of gcd(phi(p^{v_p(N)}), k).

    Valid for odd N (and for N with v_2(N) <= 2); the 2-adic case with 8 | N is the
    open exception recorded in the paper.
    """
    out = 1
    for p, e in factorise(n).items():
        out *= gcd((p - 1) * p ** (e - 1), k)
    return out


def demo_trace_lemma() -> None:
    print("=" * 78)
    print("1.  THE TRACE LEMMA:  R_k(pq) = gcd(k, p-1) * gcd(k, q-1)")
    print("=" * 78)
    for (p, q) in [(3, 5), (3, 7), (5, 7), (11, 13), (17, 19)]:
        n = p * q
        row = []
        for k in range(1, 9):
            brute = free_witness_bruteforce(n, k)
            pred = gcd(k, p - 1) * gcd(k, q - 1)
            assert brute == pred, (n, k, brute, pred)
            row.append(f"{brute:4d}")
        print(f"  N = {n:4d} = {p:2d}*{q:2d}   R_k for k=1..8: " + " ".join(row))
    print("  all brute-force counts match the closed formula.\n")

    print("  Squarefree / odd generalisation  R_k(N) = prod_p gcd(phi(p^v), k):")
    for n in [105, 231, 1155, 27, 45, 63]:
        for k in [2, 3, 4, 6, 12]:
            assert free_witness_bruteforce(n, k) == free_witness_formula(n, k)
        omega = len(factorise(n))
        print(f"    N = {n:5d} = {factorise(n)}   R_2(N) = {free_witness_bruteforce(n, 2):3d}"
              f"   (2^omega = {2**omega if all(p != 2 for p in factorise(n)) else '-'} "
              f"for odd squarefree)")
    print()

    print("  Information budget:  R_k(pq) divides k^2, so one witness leaks <= 2 log2(k) bits.")
    for (p, q, k) in [(11, 13, 6), (101, 103, 12), (10007, 10009, 30)]:
        r = free_witness_formula(p * q, k)
        assert (k * k) % r == 0
        print(f"    p={p:6d} q={q:6d} k={k:3d}:  R_k = {r:5d},  k^2 = {k*k:5d},"
              f"  R_k | k^2 -> yes   (phi(N) = {(p-1)*(q-1)})")
    print()


# --------------------------------------------------------------------------------------
# 4.  Joint closure: profile collisions
# --------------------------------------------------------------------------------------

def profile(n: int, exponents: Sequence[int]) -> Tuple[int, ...]:
    """The joint S-profile (R_k(N))_{k in S}."""
    return tuple(free_witness_formula(n, k) for k in exponents)


def saturating_primes(exponents: Sequence[int], count: int, start: int = 2) -> List[int]:
    """Primes p with k | p-1 for every k in S (Dirichlet: infinitely many exist)."""
    modulus = lcm_list(exponents)
    found: List[int] = []
    candidate = start
    while len(found) < count:
        candidate += 1
        if candidate % modulus == 1 and is_prime(candidate):
            found.append(candidate)
    return found


def demo_joint_closure() -> None:
    print("=" * 78)
    print("2.  JOINT CLOSURE:  no finite family of witnesses separates the factorisations")
    print("=" * 78)
    S = [6, 12, 15, 20, 30, 60]
    q = 7
    sat = saturating_primes(S, 6)
    print(f"  exponent set S = {S},  fixed prime q = {q}")
    print(f"  saturating primes (p = 1 mod {lcm_list(S)}): {sat}")
    profiles = {p: profile(p * q, S) for p in sat}
    for p, prof in profiles.items():
        print(f"    N = {p:5d}*{q} = {p*q:7d}   profile = {prof}")
    distinct = set(profiles.values())
    assert len(distinct) == 1, distinct
    print(f"  -> {len(profiles)} distinct semiprimes, {len(distinct)} distinct profile."
          "  No reader of the profile can name p.")
    print(f"  predicted common value  k*gcd(q-1,k):"
          f" {tuple(k * gcd(q - 1, k) for k in S)}\n")

    print("  The same happens for every exponent set; a random larger example:")
    S2 = [2, 3, 4, 5, 6, 7, 8, 9, 10]
    q2 = 11
    sat2 = saturating_primes(S2, 3)
    profs = {p: profile(p * q2, S2) for p in sat2}
    for p, prof in profs.items():
        print(f"    N = {p:7d}*{q2} = {p*q2:9d}   profile = {prof}")
    assert len(set(profs.values())) == 1
    print("  -> identical profiles again.\n")


# --------------------------------------------------------------------------------------
# 5-6.  Aggregation depth and complete witnesses
# --------------------------------------------------------------------------------------

def least_complete_exponent_bruteforce(n: int, limit: int) -> int:
    """Smallest k > 0 with R_k(N) = phi(N), searched up to `limit` (0 if not found)."""
    phi = totient(n)
    for k in range(1, limit + 1):
        if free_witness_formula(n, k) == phi:
            return k
    return 0


def factor_from_trace(n: int, s: int) -> int:
    """Phi(N, s) = (s - sqrt(s^2 - 4N)) / 2: the smaller factor, given the hint s = p+q."""
    disc = s * s - 4 * n
    if disc < 0:
        raise ValueError("no real factorisation with this trace")
    root = isqrt(disc)
    return (s - root) // 2


def demo_aggregation_depth() -> None:
    print("=" * 78)
    print("3.  AGGREGATION DEPTH:  min{k > 0 : R_k(N) = phi(N)} = lcm(p-1, q-1) = lambda(N)")
    print("=" * 78)
    print(f"  {'N = p*q':>18}  {'phi(N)':>10}  {'lcm(p-1,q-1)':>13}  {'brute min k':>11}"
          f"  {'sqrt(phi)':>9}  {'gcd(p-1,q-1)':>12}")
    for (p, q) in [(3, 5), (5, 7), (11, 13), (13, 17), (23, 29), (61, 67)]:
        n = p * q
        L = lcm(p - 1, q - 1)
        brute = least_complete_exponent_bruteforce(n, 4 * L)
        assert brute == L == carmichael(n)
        print(f"  {str(n) + ' = ' + str(p) + '*' + str(q):>18}  {totient(n):>10}  {L:>13}"
              f"  {brute:>11}  {isqrt(totient(n)):>9}  {gcd(p-1, q-1):>12}")
    print("  the least complete exponent is always exactly lcm(p-1,q-1) = phi(N)/gcd(p-1,q-1),")
    print("  i.e. of order N for cryptographic primes -- exponential in log N.\n")

    print("  A complete witness converts to the factorisation in closed form:")
    for (p, q) in [(11, 13), (61, 67), (10007, 10009)]:
        n = p * q
        k = lcm(p - 1, q - 1)
        r = free_witness_formula(n, k)
        assert r == totient(n)
        s = n + 1 - r                      # = p + q, by (p-1)(q-1) + (p+q) = pq + 1
        recovered = factor_from_trace(n, s)
        assert recovered == min(p, q)
        print(f"    N = {n:10d}:  k = lcm(p-1,q-1) = {k:8d},  R_k = phi(N) = {r:10d},"
              f"  s = N+1-R_k = {s:7d}  ->  factor {recovered}")
    print()


# --------------------------------------------------------------------------------------
# 7.  Walk sterility
# --------------------------------------------------------------------------------------

def smooth_walk(n: int, x: int, s: int, steps: int) -> List[int]:
    """The multiplicative smooth-step walk x -> x*s mod N."""
    out = [x % n]
    for _ in range(steps):
        out.append(out[-1] * s % n)
    return out


def demo_walk_sterility() -> None:
    print("=" * 78)
    print("4.  WALK STERILITY:  x -> x*s mod N never emits a nontrivial gcd")
    print("=" * 78)
    n, x, s = 8051, 3, 2                    # 8051 = 83 * 97
    walk = smooth_walk(n, x, s, 20)
    gcds = [gcd(v, n) for v in walk]
    print(f"  N = {n} = 83*97,  seed x = {x},  step s = {s}")
    print(f"  values: {walk[:12]} ...")
    print(f"  gcd(x_t, N): {gcds[:12]} ...")
    assert set(gcds) == {1}
    order = 1
    v = s % n
    while v != 1:
        v = v * s % n
        order += 1
    print(f"  every value is a unit, so the gcd channel is identically trivial.")
    print(f"  ord_N(s) = {order}, and lambda(N) = {carmichael(n)}: the orbit is a coset of <s>,")
    print(f"  so the walk revisits its seed after {order} steps -- no randomness beyond <s>.\n")


# --------------------------------------------------------------------------------------
# 8.  The residue witness (the coordinate the quantum channel reads)
# --------------------------------------------------------------------------------------

def crt_sqrt_of_one(p: int, q: int) -> int:
    """The residue that is 1 mod p and -1 mod q: a nontrivial square root of 1 mod pq."""
    n = p * q
    inv = pow(q, -1, p)                      # q * inv = 1 mod p
    # a = -1 + 2 * q * ((q^{-1} mod p) mod p)  satisfies a = 1 mod p, a = -1 mod q
    a = (-1 + 2 * q * inv) % n
    assert a % p == 1 % p and a % q == (q - 1) % q
    return a


def demo_residue_witness() -> None:
    print("=" * 78)
    print("5.  RESIDUE WITNESS:  a^2 = 1, a != +-1  =>  gcd(a-1, N) is a prime factor")
    print("=" * 78)
    for (p, q) in [(83, 97), (10007, 10009), (65537, 65539 if is_prime(65539) else 65543)]:
        n = p * q
        a = crt_sqrt_of_one(p, q)
        assert pow(a, 2, n) == 1 and a != 1 and a != n - 1
        g = gcd(a - 1, n)
        assert g in (p, q) and n % g == 0
        print(f"  N = {n:12d} = {p}*{q}")
        print(f"    a = {a:12d},  a^2 mod N = {pow(a,2,n)},  a != +-1")
        print(f"    gcd(a-1, N) = {g}  ->  a prime factor, from a single gcd")
    print()
    print("  population of the coordinate (trace lemma with k = 2):")
    for n in [83 * 97, 3 * 5 * 7, 3 * 5 * 7 * 11]:
        roots = [x for x in range(1, n) if gcd(x, n) == 1 and pow(x, 2, n) == 1]
        omega = len(factorise(n))
        print(f"    N = {n:6d}: R_2(N) = {len(roots):3d} = 2^omega(N) = 2^{omega};"
              f"  {len(roots)-2} of them split N")
    print("  the useful witness is half of all square roots of unity -- common, but")
    print("  classically expensive to locate: that search cost is the aggregation barrier.\n")


# --------------------------------------------------------------------------------------
# 9.  Hint amplification
# --------------------------------------------------------------------------------------

def demo_hint_amplification() -> None:
    print("=" * 78)
    print("6.  HINT AMPLIFICATION:  Phi(N, p+q) = p, in closed form")
    print("=" * 78)
    for (p, q) in [(83, 97), (10007, 10009), (1000003, 1000033)]:
        n, s = p * q, p + q
        rec = factor_from_trace(n, s)
        assert rec == min(p, q) and n % rec == 0
        print(f"  N = {n:14d}, hint s = p+q = {s:8d}"
              f"  ->  Phi = (s - sqrt(s^2-4N))/2 = {rec}   (N/{rec} = {n//rec})")
    print()
    print("  Uniqueness: (N, s) determines the ordered factor pair.")
    print("  Contrast with the hint-free channel, where NO extractor exists at all.")
    print()


def main() -> None:
    print()
    print("FREE WITNESSES, AGGREGATION DEPTH, AND THE QUANTUM BYPASS")
    print("Numerical demonstrations")
    print()
    demo_trace_lemma()
    demo_joint_closure()
    demo_aggregation_depth()
    demo_walk_sterility()
    demo_residue_witness()
    demo_hint_amplification()
    print("=" * 78)
    print("All assertions passed: every displayed value matches the theory.")
    print("=" * 78)


if __name__ == "__main__":
    main()
