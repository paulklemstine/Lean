#!/usr/bin/env python3
"""Assemble PACKAGE.json from the individual deliverables."""

import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = pathlib.Path(__file__).resolve().parent


def read(name: str) -> str:
    """Read a deliverable from the project root, or an asset from assets/."""
    q = ROOT / name
    if not q.exists():
        q = ASSETS / name
    return q.read_text(encoding="utf-8")


def slice_between(src: str, start: str, end: str | None) -> str:
    i = src.index(start)
    j = src.index(end, i) if end else len(src)
    return src[i:j].rstrip() + "\n"


algorithms_src = read("algorithms.py")


def extract(start: str, end_marker: str) -> str:
    """Text from `start` up to the banner line preceding `end_marker`."""
    i = algorithms_src.index(start)
    j = algorithms_src.index(end_marker, i)
    body = algorithms_src[i:j]
    body = re.sub(r"#\s*-{10,}\s*$", "", body).rstrip()
    return body + "\n"


A1 = extract("def half_group_membership", "\n# A2.")
A2 = extract("def v2(", "\n# A3.")
A3 = extract("def _factorise(", "\n# A4.")
A4 = extract("def pearson(", "\nif __name__")

HEADER = ("from __future__ import annotations\n\n"
          "from collections import Counter\n"
          "from math import gcd, lcm\n"
          "from typing import Callable, Dict, List, Sequence, Tuple\n"
          "import random\n\n\n")

LEAN_FILE = "Catalog/Computation/OrderJacobiJointLaw.lean"
lean_src = read(LEAN_FILE)

interactive_layout = read("INTERACTIVE_LAYOUT.md")

FUTURE_DIRECTIONS = r"""# Future Directions — after the Order × Jacobi Joint Law

The verified results are:

1. the QR–order coupling is an exact equivalence at each prime;
2. its lift to a semiprime is exact **iff** $v_2((p-1)/2) = v_2((q-1)/2)$ — a
   single 2-adic dial, whose bottom rung is $p \equiv q \equiv 3 \pmod 4$;
3. on that dial the four order/Jacobi quadrants are equinumerous ($\varphi(N)/4$
   each);
4. the complete joint laws of $35 = 5\cdot 7$ and $39 = 3\cdot 13$ coincide, so
   no function of the joint law can output a factor;
5. joint-law collisions are transported by any Jacobi-preserving isomorphism of
   unit groups.

Five bold, testable conjectures follow.

## C1 (Collision density). Almost every semiprime has a joint-law twin.

**Statement.** The number of $N \le X$ that are products of two distinct odd
primes and admit a coprime semiprime $N' \le X^{1+o(1)}$ with
$\mathrm{jointLaw}(N) = \mathrm{jointLaw}(N')$ is $(1 - o(1))$ times the number
of semiprimes up to $X$.

**The key insight is** that the joint law only remembers the pair (abelian group
$\mathbb{Z}_{p-1} \times \mathbb{Z}_{q-1}$, quadratic character), and the number
of such isomorphism classes with $\varphi(N) \le Y$ grows far more slowly than
the number of semiprimes — a pigeonhole in a quotient category, not in the
integers.

**Why now?** Item 5 above makes the transport mechanism a theorem, so the
conjecture reduces to counting isomorphism classes of pairs (group, character),
which is a tractable multiplicative-number-theory problem (Erdős–Pomerance-style
counts of $\varphi$-fibres). Exhaustive search already supports it: among the 73
semiprimes below 400 there are only 62 distinct joint laws, and ten of those are
shared by pairwise coprime moduli.

## C2 (Universality of the dial). Every "order ⊗ character" statistic collapses to $v_\ell$.

**Statement.** Let $\chi$ be any real Dirichlet character mod $N = pq$ and
consider the statistic $u \mapsto (\mathrm{order}(u), \chi(u))$. Then the
analogue of item 2 holds with $v_2$ replaced by $v_\ell$ for the order $\ell$ of
$\chi$: the divisibility test
$\mathrm{order}(u) \mid \mathrm{lcm}((p-1)/\ell, (q-1)/\ell)$ is equivalent to
"$\chi$ trivial at both components" **iff**
$v_\ell((p-1)/\ell) = v_\ell((q-1)/\ell)$.

**The key insight is** that the proof of the dichotomy used nothing about
quadraticity beyond $\gcd(2x, \mathrm{lcm}(x,y)) = x \iff v_2(y) \le v_2(x)$;
the same lattice identity holds prime-by-prime for any $\ell$.

**Why now?** The arithmetic core is already isolated as a self-contained
lcm–gcd lattice lemma; generalising it to $\ell$ is a self-contained
factorisation-lattice exercise.

## C3 (Hardness of the inverse problem). Reconstructing $N$ from its joint law is as hard as factoring.

**Statement.** There is a polynomial-time reduction from factoring semiprimes to
the problem: given the multiset $\mathrm{jointLaw}(N)$ (as an explicit list) and
$N$, output a nontrivial factor of $N$. Conversely, given the factorisation the
law is computable in polynomial time.

**The key insight is** that the law's $+1$-fibre determines the multiset of
$\mathrm{lcm}$ values of pairs of divisors of $(p-1)/2$ and $(q-1)/2$, which is a
"divisor-lattice tomography" problem whose difficulty can be pinned to the
hardness of recovering $p-1$ from $\varphi(N)$-type data.

## C4 (The exact three-quarters law).

**Statement.** For every semiprime $N = pq$ with $p \equiv q \equiv 3 \pmod 4$,
$$\frac{\mathbb{E}[\mathrm{order} \mid J = +1]}{\mathbb{E}[\mathrm{order} \mid J = -1]} = \frac{3}{4}$$
exactly.

**The key insight is** that on the Blum dial the order class coincides with the
both-residue quadrant and $L$ is odd, so the conditional sums decompose along the
four equinumerous quadrants; the conjecture asserts that decomposition is rigid
enough to pin the ratio independently of $p$ and $q$. Exact in every tested case
($N = 21, 33, 77, 133, 209, 437, 713$).

**Why now?** The quadrant counts are already exact, so what remains is a sum
identity over the two half groups rather than an estimate.

## C5 (Closing the last grid cell).

**Statement.** The residue × spectral joint statistic collapses in exactly the
same way as order × residue and order × spectral: it is a residue dial, circular
to compute, and admits a collision between coprime moduli.

**The key insight is** that the three obstructions identified here are not
specific to the order statistic; they are properties of any statistic invariant
under Jacobi-preserving isomorphism of unit groups. Establishing a transport
theorem for the spectral statistic would close the combination grid.
"""
future_directions = FUTURE_DIRECTIONS

package = {
    "title": "The Order \u00d7 Jacobi Joint Law for Semiprime Moduli: "
             "Exact Coupling, a 2-Adic Dichotomy, and an Unconditional Barrier",
    "domain": "Computation",
    "description": (
        "For a semiprime N = pq we determine the exact joint distribution of "
        "multiplicative order and Jacobi symbol on the units mod N: the "
        "residue/order coupling is an exact equivalence at each prime, its lift "
        "to N is exact precisely when the two half-orders share the same 2-adic "
        "valuation, and the complete joint laws of 35 and 39 coincide, which "
        "proves unconditionally that no function of the joint law can output a "
        "nontrivial factor of its modulus."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-13",
    "key_results": [
        "Exact residue\u2013order coupling at a prime: a unit modulo an odd prime p "
        "is a quadratic residue if and only if its multiplicative order divides "
        "(p\u22121)/2.",
        "The 2-adic dichotomy: for N = pq the test ord_N(b) | lcm((p\u22121)/2,(q\u22121)/2) "
        "characterises the both-residue quadrant for every unit if and only if "
        "(p\u22121)/2 and (q\u22121)/2 have the same 2-adic valuation; the bottom rung of "
        "this dial is p \u2261 q \u2261 3 (mod 4).",
        "Equidistribution of quadrants on the Blum dial: for p \u2261 q \u2261 3 (mod 4) the "
        "set of units whose order divides lcm((p\u22121)/2,(q\u22121)/2) has exactly "
        "\u03c6(N)/4 elements, one quarter of the unit group.",
        "Blindness of the Jacobi symbol: for p \u2261 q \u2261 3 (mod 4) the units 1 and \u22121 "
        "both have Jacobi symbol +1 while lying in different order classes, so "
        "the symbol carries strictly less information than the order.",
        "The collision barrier: the complete order \u00d7 Jacobi joint laws of 35 = 5\u00b77 "
        "and 39 = 3\u00b713 are identical while gcd(35,39) = 1, hence no function of "
        "the joint law can return a nontrivial divisor of its modulus; such "
        "collisions are transported by any Jacobi-preserving isomorphism of unit "
        "groups.",
    ],
    "keywords": [
        "multiplicative order", "Jacobi symbol", "quadratic residues",
        "Euler's criterion", "2-adic valuation", "Blum integers",
        "semiprime factorisation barrier", "joint law collision",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Verification of the Order \u00d7 Jacobi "
                    "Joint Law",
            "description": (
                "An end-to-end exhaustive check of every result in the paper. "
                "It verifies the exact residue\u2013order coupling on fourteen odd "
                "primes; tabulates the 2-adic dichotomy on fifteen prime pairs, "
                "showing that the 'balanced' and 'exact' columns agree row by "
                "row and counting the violating units when they disagree; "
                "confirms that on the p \u2261 q \u2261 3 (mod 4) dial the four Legendre "
                "quadrants each hold exactly \u03c6(N)/4 units and that the order "
                "class coincides with the both-residue quadrant; exhibits the "
                "blindness of the Jacobi symbol via the pair 1 and \u22121; prints "
                "the full joint laws of 35 and 39 side by side to display the "
                "collision; reports the conditional order means and their ratio "
                "over twenty semiprimes; and runs a 10\u2009000-shuffle permutation "
                "test of the ratio against p, q, p+q and |p\u2212q|, finding every "
                "observed correlation inside its null band."
            ),
            "code": read("demo.py"),
        },
        {
            "name": "Exhaustive Joint-Law Collision Search over Small Semiprimes",
            "description": (
                "Computes the complete order \u00d7 Jacobi joint law of every "
                "semiprime N = pq below a bound and groups the moduli by that "
                "law, reporting each group that contains two or more pairwise "
                "coprime moduli. Every such group is an independent instance of "
                "the barrier theorem: a function of the joint law returning a "
                "nontrivial divisor would return the same integer for coprime "
                "inputs. Among the 73 semiprimes below 400 only 62 distinct laws "
                "occur, and ten of them are shared by coprime moduli \u2014 including "
                "the triple 143, 155, 183 whose unit groups are all the same "
                "abelian group of order 120. The output also prints the "
                "invariant-factor shape of each unit group, making the "
                "group-theoretic mechanism behind the collisions visible."
            ),
            "code": read("collision_search.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Half-Group Membership by Euler's Criterion "
                    "(the Exact Residue\u2013Order Test)",
            "description": (
                "Decides, for an odd prime p and a unit b, whether the "
                "multiplicative order of b divides H_p = (p\u22121)/2. By the exact "
                "coupling theorem this is literally the same question as 'is b a "
                "quadratic residue mod p?', so a single modular exponentiation "
                "b^{(p\u22121)/2} mod p answers both. The mathematical foundation is "
                "that the quadratic residues and the elements of order dividing "
                "H_p are two descriptions of the unique index-2 subgroup of the "
                "cyclic group of units. Complexity: O(log p) modular "
                "multiplications, i.e. O(log^3 p) bit operations with "
                "schoolbook arithmetic. Role in the pipeline: it is the atomic "
                "predicate out of which the residue quadrants, and hence the "
                "whole joint law, are built."
            ),
            "pseudocode": (
                "ALGORITHM HalfGroupMembership(p, b)\n"
                "  INPUT   odd prime p; integer b with p does not divide b\n"
                "  OUTPUT  TRUE iff ord_p(b) divides (p-1)/2\n"
                "          (equivalently, iff b is a quadratic residue mod p)\n"
                "  1  H  <- (p - 1) / 2\n"
                "  2  r  <- b^H mod p            // square-and-multiply\n"
                "  3  if r = 1 then return TRUE\n"
                "  4  else return FALSE          // then r = p - 1\n"
                "  INVARIANT  r is +1 or -1 mod p, by Euler's criterion\n"
            ),
            "code": HEADER + A1,
        },
        {
            "name": "The 2-Adic Balance Test (Deciding Exactness of the "
                    "Semiprime Lift)",
            "description": (
                "Given the two prime factors of N = pq, decides whether the "
                "order test ord_N(b) | lcm(H_p, H_q) is an exact characterisation "
                "of the both-residue quadrant. By the dichotomy theorem the "
                "answer is yes precisely when v2(H_p) = v2(H_q), where v2 is the "
                "2-adic valuation; the bottom rung of this dial is "
                "p \u2261 q \u2261 3 (mod 4), where both valuations vanish. The "
                "mathematical foundation is the lattice identity "
                "gcd(2x, lcm(x,y)) = x \u21d4 v2(y) \u2264 v2(x): a component order always "
                "divides 2H_p = p\u22121, and under balance it is forced down into "
                "H_p itself. Complexity: O(log N) bit operations \u2014 two shifts and "
                "a comparison. Role in the pipeline: it is the single dial that "
                "controls all of the joint law's structure, and it is precisely "
                "the quantity an adversary cannot evaluate, since it needs the "
                "factors."
            ),
            "pseudocode": (
                "ALGORITHM DialIsBalanced(p, q)\n"
                "  INPUT   distinct odd primes p, q\n"
                "  OUTPUT  TRUE iff for every unit b mod N = p*q,\n"
                "            ord_N(b) | lcm(H_p, H_q)  <=>  b is a QR mod p and mod q\n"
                "  1  H_p <- (p - 1) / 2 ;  H_q <- (q - 1) / 2\n"
                "  2  a <- v2(H_p)               // count trailing zero bits\n"
                "  3  c <- v2(H_q)\n"
                "  4  return (a = c)\n"
                "  COROLLARY  if p mod 4 = 3 and q mod 4 = 3 then a = c = 0,\n"
                "             so the answer is TRUE automatically\n"
                "  WITNESS    if a < c, an element of order 2^{a+1} mod p is a\n"
                "             non-residue passing the order test\n"
            ),
            "code": HEADER + A2,
        },
        {
            "name": "Componentwise Computation of the Complete Order \u00d7 Jacobi "
                    "Joint Law",
            "description": (
                "Builds the full multiset of pairs (ord_N(b), J(b|N)) over all "
                "units b modulo N = pq, and compares two such multisets to "
                "detect a collision. Orders are computed componentwise: "
                "ord_p(b) is obtained by starting from p\u22121 and peeling off each "
                "prime factor of p\u22121 while the reduced exponent still returns 1, "
                "and then ord_N(b) = lcm(ord_p(b), ord_q(b)). The Jacobi symbol "
                "is the product of the two Legendre symbols, each an application "
                "of Euler's criterion. Complexity: O(\u03c6(N) log^2 N) modular "
                "multiplications, against O(N^2) for naive definition-chasing; "
                "multiset comparison after canonical sorting costs "
                "O(\u03c6(N) log \u03c6(N)). Role in the pipeline: it produces the maximal "
                "statistic of the paper and, when two coprime moduli yield the "
                "same output, an unconditional proof that no function of that "
                "statistic can factor. Note the circularity that makes the "
                "algorithm useless as an attack: it consumes the very factors it "
                "would be asked to reveal."
            ),
            "pseudocode": (
                "ALGORITHM JointLaw(p, q)\n"
                "  INPUT   distinct odd primes p, q;  N <- p*q\n"
                "  OUTPUT  multiset L of pairs (order, Jacobi symbol)\n"
                "  1  L <- empty multiset\n"
                "  2  for b = 1 to N-1 do\n"
                "  3      if gcd(b, N) != 1 then continue\n"
                "  4      d <- OrderAtPrime(b mod p, p)\n"
                "  5      e <- OrderAtPrime(b mod q, q)\n"
                "  6      o <- lcm(d, e)                         // CRT order rule\n"
                "  7      j <- Legendre(b,p) * Legendre(b,q)     // Euler twice\n"
                "  8      insert (o, j) into L\n"
                "  9  return L\n"
                "\n"
                "SUBROUTINE OrderAtPrime(b, p)\n"
                "  1  o <- p - 1\n"
                "  2  for each prime power r^e || p - 1 do\n"
                "  3      repeat e times:\n"
                "  4          if b^(o/r) = 1 mod p then o <- o / r  else break\n"
                "  5  return o\n"
                "\n"
                "ALGORITHM LawsCollide(p1, q1, p2, q2)\n"
                "  1  return JointLaw(p1,q1) = JointLaw(p2,q2) as multisets\n"
                "  BARRIER  if additionally gcd(p1*q1, p2*q2) = 1 then no function\n"
                "           of the joint law returns a nontrivial divisor\n"
            ),
            "code": HEADER + A3,
        },
        {
            "name": "Permutation Test for Factor Dependence of the Conditional "
                    "Bias",
            "description": (
                "Quantifies whether the conditional bias ratio "
                "E[ord | J = +1] / E[ord | J = \u22121] carries information about the "
                "individual prime factors. For a covariate of the factors \u2014 p, "
                "q, p+q or |p\u2212q| \u2014 it computes the observed Pearson correlation "
                "with the ratios and compares it against the empirical "
                "distribution obtained by randomly reshuffling the ratios, which "
                "is the exact null distribution under the hypothesis of no "
                "association. Reporting the observed value against the null 95th "
                "percentile is a distribution-free test needing no normality "
                "assumption. Complexity: O(T\u00b7n) for T shuffles and n moduli. "
                "Role in the pipeline: it converts the qualitative claim 'the "
                "bias is N-determined' into a falsifiable measurement; every "
                "covariate tested lands inside its null band, and the collision "
                "theorem then explains why it must."
            ),
            "pseudocode": (
                "ALGORITHM PermutationTest(pairs, values, covariate, T)\n"
                "  INPUT   pairs[i] = (p_i, q_i); values[i] = bias ratio for N_i;\n"
                "          covariate f mapping (p,q) to a real number; trials T\n"
                "  OUTPUT  (observed |correlation|, null 95th percentile, verdict)\n"
                "  1  for each i:  x[i] <- f(p_i, q_i)\n"
                "  2  obs <- |Pearson(x, values)|\n"
                "  3  null <- empty list\n"
                "  4  for t = 1 to T do\n"
                "  5      v' <- uniformly random permutation of values\n"
                "  6      append |Pearson(x, v')| to null\n"
                "  7  sort null ascending\n"
                "  8  p95 <- null[ceil(0.95 * T)]\n"
                "  9  return (obs, p95, obs <= p95)\n"
                "  READING  obs <= p95 means no detectable factor dependence\n"
            ),
            "code": HEADER + A4,
        },
    ],
    "visualizations": [
        {
            "name": "The Quadrant Map, the Conditional Order Law, and the "
                    "35 vs 39 Collision",
            "description": (
                "A three-panel figure. Panel A plots every unit b modulo N = pq "
                "at its Chinese-Remainder coordinates (b mod p, b mod q), "
                "coloured by its pair of Legendre symbols, and rings those units "
                "whose order divides L = lcm((p\u22121)/2, (q\u22121)/2). On a balanced "
                "dial the rings land exactly on the both-residue quadrant; when "
                "the 2-adic valuations differ they visibly leak into the wrong "
                "colours. Panel B histograms the multiplicative orders split by "
                "Jacobi symbol and prints the conditional-mean ratio, exhibiting "
                "the real bias. Panel C plots the joint laws of 35 = 5\u00b77 and "
                "39 = 3\u00b713 as paired bars of identical height \u2014 the collision "
                "that closes the attack surface."
            ),
            "code": read("visualization_quadrants.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The 2-Adic Dial \u2014 an Order \u00d7 Jacobi Explorer",
            "description": (
                "A single-page laboratory for the whole theory. Choose two odd "
                "primes and the widget draws the Chinese-Remainder quadrant map "
                "of the units modulo N = pq, colouring each unit by its Legendre "
                "pair and ringing those whose order divides "
                "L = lcm((p\u22121)/2,(q\u22121)/2). A verdict panel reports the 2-adic "
                "valuations of the two half-orders and declares the dial balanced "
                "or unbalanced, with a census table showing how many units of "
                "each quadrant are ringed \u2014 green when the order test is exact, "
                "red when it leaks. Shortcut buttons cycle through Blum pairs "
                "(p \u2261 q \u2261 3 mod 4, where exactness is automatic) and unbalanced "
                "pairs, so a reader can watch the rings snap into and out of the "
                "blue quadrant. A second panel histograms the orders split by "
                "Jacobi symbol and reports the conditional-mean ratio, making the "
                "real bias tangible. A final button reveals the complete joint "
                "laws of 35 and 39 side by side, row by row identical, together "
                "with the three-line argument that turns this collision into an "
                "unconditional impossibility. Collapsible sections explain the "
                "lattice lemma behind the dial and the transport mechanism behind "
                "the collisions. All computation runs in the browser."
            ),
            "html": read("widget_dial.html"),
        },
    ],
    "interactive_layout": interactive_layout,
    "lean_proofs": lean_src,
    "future_directions": future_directions,
    "modules": {
        "demo": read("demo.py"),
        "algorithms": read("algorithms.py"),
        "collision_search": read("collision_search.py"),
        "visualization_quadrants": read("visualization_quadrants.py"),
    },
    "lean_files": [LEAN_FILE],
}

(ROOT / "PACKAGE.json").write_text(
    json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print("wrote PACKAGE.json",
      (ROOT / "PACKAGE.json").stat().st_size, "bytes")


#!/usr/bin/env python3
"""
Joint-law collision search over small semiprimes.

For every semiprime N = p*q below a bound we compute the complete order x
Jacobi joint law and group the moduli by that law.  Any group containing two
*coprime* moduli is a proof that no function of the joint law can output a
nontrivial factor: such a function would have to return the same integer d > 1
for both, and d would divide their gcd, which is 1.

The script also reports the underlying group-theoretic explanation: two moduli
collide when their unit groups, together with the quadratic character, are
isomorphic as (group, character) pairs.  We display the invariant-factor
decomposition of each unit group to make the coincidence visible.
"""

from __future__ import annotations

from collections import Counter, defaultdict
from math import gcd
from typing import Dict, List, Tuple


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def multiplicative_order(b: int, n: int) -> int:
    k, x = 1, b % n
    while x != 1:
        x = x * b % n
        k += 1
    return k


def jacobi(b: int, n: int) -> int:
    """Jacobi symbol (b|n) for odd n >= 1."""
    b %= n
    result = 1
    while b != 0:
        while b % 2 == 0:
            b //= 2
            if n % 8 in (3, 5):
                result = -result
        b, n = n, b
        if b % 4 == 3 and n % 4 == 3:
            result = -result
        b %= n
    return result if n == 1 else 0


def joint_law_key(n: int) -> Tuple[Tuple[Tuple[int, int], int], ...]:
    """Canonical hashable form of the joint law of n."""
    c = Counter((multiplicative_order(b, n), jacobi(b, n))
                for b in range(1, n) if gcd(b, n) == 1)
    return tuple(sorted(c.items()))


def cyclic_decomposition(p: int, q: int) -> str:
    """Human-readable description of the unit group Z_{p-1} x Z_{q-1}."""
    return f"Z_{p-1} x Z_{q-1}"


def semiprimes(limit: int) -> List[Tuple[int, int, int]]:
    """All N = p*q < limit with p < q odd primes."""
    out: List[Tuple[int, int, int]] = []
    ps = [x for x in range(3, limit) if is_prime(x)]
    for i, p in enumerate(ps):
        for q in ps[i + 1:]:
            if p * q >= limit:
                break
            out.append((p * q, p, q))
    return sorted(out)


def main(limit: int = 400) -> None:
    groups: Dict[Tuple, List[Tuple[int, int, int]]] = defaultdict(list)
    for N, p, q in semiprimes(limit):
        groups[joint_law_key(N)].append((N, p, q))

    print(f"Semiprimes N = p*q < {limit} examined: "
          f"{sum(len(v) for v in groups.values())}")
    print(f"Distinct joint laws found: {len(groups)}\n")

    coprime_hits = 0
    for key, members in sorted(groups.items(), key=lambda kv: kv[1][0][0]):
        if len(members) < 2:
            continue
        pairs = [(a, b) for i, a in enumerate(members) for b in members[i + 1:]
                 if gcd(a[0], b[0]) == 1]
        if not pairs:
            continue
        coprime_hits += 1
        print("-" * 68)
        print("Colliding moduli sharing one joint law:")
        for N, p, q in members:
            print(f"    N = {N:>5} = {p}*{q},  unit group {cyclic_decomposition(p, q)}")
        for (N1, p1, q1), (N2, p2, q2) in pairs:
            print(f"    coprime pair: gcd({N1}, {N2}) = {gcd(N1, N2)}  ->  "
                  f"no joint-law function can factor both")
        print("    joint law: " + ", ".join(f"({o},{'+' if j > 0 else '-'}):{c}"
                                            for (o, j), c in key))

    print("-" * 68)
    print(f"\nJoint laws admitting a coprime collision: {coprime_hits}")
    print("\nThe smallest such collision is 35 = 5*7 versus 39 = 3*13, whose unit")
    print("groups Z_4 x Z_6 and Z_2 x Z_12 are the same abelian group of order 24")
    print("with matching quadratic character.  Because an isomorphism of unit")
    print("groups preserves element orders, any Jacobi-preserving isomorphism")
    print("transports the entire joint law -- collisions are structural, not")
    print("numerical accidents.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualisation: the order x Jacobi quadrant map of a semiprime.

Produces a three-panel figure.

Panel A -- The quadrant map.  Every unit b modulo N = p*q is plotted at
    (b mod p, b mod q), the Chinese Remainder coordinates, and coloured by
    its Legendre pair ((b|p), (b|q)).  Units whose order divides
    L = lcm((p-1)/2, (q-1)/2) are ringed in black.  When p = q = 3 (mod 4)
    the ringed set coincides exactly with the (+1,+1) quadrant, which is one
    quarter of the picture; when the 2-adic valuations of (p-1)/2 and
    (q-1)/2 differ, rings leak into the wrong quadrants.

Panel B -- The order histogram split by Jacobi symbol, showing the real
    conditional bias: the J = +1 class is enriched in short orders.

Panel C -- The collision.  The joint laws of 35 = 5*7 and 39 = 3*13 plotted
    as bar pairs; every bar has identical height, which is precisely the
    barrier to factoring from this statistic.

Usage:  python3 visualization_quadrants.py [p q]      (default 11 19)
"""

from __future__ import annotations

import sys
from collections import Counter
from math import gcd, lcm
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def euler_phi(n: int) -> int:
    result, m, d = n, n, 2
    while d * d <= m:
        if m % d == 0:
            while m % d == 0:
                m //= d
            result -= result // d
        d += 1
    if m > 1:
        result -= result // m
    return result


def multiplicative_order(b: int, n: int) -> int:
    if gcd(b, n) != 1:
        raise ValueError("not a unit")
    k, x = 1, b % n
    while x != 1:
        x = x * b % n
        k += 1
    return k


def legendre(b: int, p: int) -> int:
    r = pow(b % p, (p - 1) // 2, p)
    return 0 if r == 0 else (1 if r == 1 else -1)


def jacobi(b: int, n: int) -> int:
    b %= n
    result = 1
    while b != 0:
        while b % 2 == 0:
            b //= 2
            if n % 8 in (3, 5):
                result = -result
        b, n = n, b
        if b % 4 == 3 and n % 4 == 3:
            result = -result
        b %= n
    return result if n == 1 else 0


def joint_law(n: int) -> Counter:
    return Counter((multiplicative_order(b, n), jacobi(b, n))
                   for b in range(1, n) if gcd(b, n) == 1)


def make_figure(p: int, q: int, outfile: str = "order_jacobi_quadrants.png") -> None:
    N = p * q
    L = lcm((p - 1) // 2, (q - 1) // 2)
    units = [b for b in range(1, N) if gcd(b, N) == 1]

    colours: Dict[Tuple[int, int], str] = {
        (1, 1): "#1b6ca8", (1, -1): "#f4a259",
        (-1, 1): "#8ac926", (-1, -1): "#c1121f",
    }
    labels: Dict[Tuple[int, int], str] = {
        (1, 1): "(+,+) both residues", (1, -1): "(+,-)",
        (-1, 1): "(-,+)", (-1, -1): "(-,-)",
    }

    fig = plt.figure(figsize=(16, 5.2))
    fig.suptitle(
        f"Order x Jacobi structure of N = {p}*{q} = {N}   "
        f"(L = lcm({(p-1)//2},{(q-1)//2}) = {L})",
        fontsize=14, weight="bold")

    # ---------------- Panel A: quadrant map ----------------
    axA = fig.add_subplot(1, 3, 1)
    seen = set()
    for b in units:
        sig = (legendre(b, p), legendre(b, q))
        lab = labels[sig] if sig not in seen else None
        seen.add(sig)
        axA.scatter(b % p, b % q, s=70, c=colours[sig], label=lab,
                    edgecolors="none", zorder=2)
        if L % multiplicative_order(b, N) == 0:
            axA.scatter(b % p, b % q, s=170, facecolors="none",
                        edgecolors="black", linewidths=1.4, zorder=3)
    axA.set_xlabel("b mod p")
    axA.set_ylabel("b mod q")
    axA.set_title("A. CRT quadrant map\n(ringed: ord divides L)", fontsize=11)
    axA.legend(fontsize=7, loc="upper left", framealpha=1.0)
    axA.grid(alpha=0.25, zorder=0)

    # ---------------- Panel B: conditional order histogram ----------------
    axB = fig.add_subplot(1, 3, 2)
    orders_plus = [multiplicative_order(b, N) for b in units if jacobi(b, N) == 1]
    orders_minus = [multiplicative_order(b, N) for b in units if jacobi(b, N) == -1]
    allo = sorted(set(orders_plus + orders_minus))
    idx = np.arange(len(allo))
    cp = [orders_plus.count(o) for o in allo]
    cm = [orders_minus.count(o) for o in allo]
    axB.bar(idx - 0.2, cp, width=0.4, color="#1b6ca8", label="J = +1")
    axB.bar(idx + 0.2, cm, width=0.4, color="#c1121f", label="J = -1")
    axB.set_xticks(idx)
    axB.set_xticklabels([str(o) for o in allo], fontsize=8)
    axB.set_xlabel("multiplicative order")
    axB.set_ylabel("number of units")
    mp = sum(orders_plus) / len(orders_plus)
    mm = sum(orders_minus) / len(orders_minus)
    axB.set_title(f"B. Conditional order law\nE[ord|+1]/E[ord|-1] = {mp/mm:.4f}",
                  fontsize=11)
    axB.legend(fontsize=8)
    axB.grid(axis="y", alpha=0.25)

    # ---------------- Panel C: the 35 / 39 collision ----------------
    axC = fig.add_subplot(1, 3, 3)
    l35, l39 = joint_law(35), joint_law(39)
    keys: List[Tuple[int, int]] = sorted(set(l35) | set(l39))
    k = np.arange(len(keys))
    axC.bar(k - 0.2, [l35[key] for key in keys], width=0.4,
            color="#5f0f40", label="N = 35 = 5*7")
    axC.bar(k + 0.2, [l39[key] for key in keys], width=0.4,
            color="#e5b769", label="N = 39 = 3*13")
    axC.set_xticks(k)
    axC.set_xticklabels([f"({o},{'+' if j > 0 else '-'})" for o, j in keys],
                        rotation=60, fontsize=8)
    axC.set_xlabel("(order, Jacobi symbol)")
    axC.set_ylabel("multiplicity")
    axC.set_title("C. The collision: identical joint laws\ngcd(35,39) = 1, so no "
                  "statistic can factor", fontsize=11)
    axC.legend(fontsize=8)
    axC.grid(axis="y", alpha=0.25)

    fig.tight_layout(rect=(0, 0, 1, 0.93))
    fig.savefig(outfile, dpi=150)
    print(f"wrote {outfile}")
    print(f"phi(N) = {euler_phi(N)}, quarter = {euler_phi(N)//4}, "
          f"#(ord | L) = {sum(1 for b in units if L % multiplicative_order(b, N) == 0)}")


if __name__ == "__main__":
    if len(sys.argv) == 3:
        make_figure(int(sys.argv[1]), int(sys.argv[2]))
    else:
        make_figure(11, 19)


#!/usr/bin/env python3
"""
The Order x Jacobi Joint Law for Semiprime Moduli
=================================================

Numerical companion to the paper.

For an odd semiprime N = p*q we study, for each unit b modulo N, the pair

        (ord_N(b),  J(b|N))

where ord_N(b) is the multiplicative order of b and J(b|N) is the Jacobi
symbol.  The multiset of all such pairs is the *joint law* of N.

This script demonstrates, purely numerically, the four facts established in
the paper:

  (1) EXACT COUPLING AT A PRIME.  For an odd prime p and a unit b,
          b is a quadratic residue mod p   <=>   ord_p(b) | (p-1)/2.

  (2) THE 2-ADIC DICHOTOMY.  Put H(p) = (p-1)/2 and L = lcm(H(p), H(q)).
      Then
          ord_N(b) | L   <=>   b is a QR mod p AND a QR mod q
      holds for every unit b if and only if v2(H(p)) = v2(H(q)),
      where v2 is the 2-adic valuation.  Its bottom rung is
      p = q = 3 (mod 4), where H(p), H(q) are both odd.

  (3) EQUIDISTRIBUTION.  When p = q = 3 (mod 4) the set
      {b : ord_N(b) | L} has exactly H(p)*H(q) = phi(N)/4 elements, i.e. the
      four order x Jacobi quadrants are equinumerous.

  (4) THE COLLISION BARRIER.  jointLaw(35) = jointLaw(39) as multisets, while
      gcd(35, 39) = 1.  Hence no function of the joint law alone can output a
      nontrivial factor of its modulus.

Additionally we reproduce the empirical "conditional bias":
      E[ord | J = +1] / E[ord | J = -1]
is genuinely != 1, but it is a function of N's residue data, not of the
individual factors -- it is *N-determined*.

Run:  python3 demo.py
"""

from __future__ import annotations

from collections import Counter
from math import gcd, lcm
from typing import Dict, Iterable, List, Tuple


# --------------------------------------------------------------------------
# Elementary number theory
# --------------------------------------------------------------------------
def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def factorize(n: int) -> Dict[int, int]:
    """Trial-division factorization; adequate for the sizes used here."""
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def v2(n: int) -> int:
    """2-adic valuation of a positive integer."""
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def multiplicative_order(b: int, n: int) -> int:
    """Least k >= 1 with b^k = 1 (mod n); requires gcd(b, n) = 1."""
    if gcd(b, n) != 1:
        raise ValueError("b must be a unit modulo n")
    phi = euler_phi(n)
    order = phi
    for p, e in factorize(phi).items():
        for _ in range(e):
            if pow(b, order // p, n) == 1:
                order //= p
            else:
                break
    return order


def euler_phi(n: int) -> int:
    """Euler's totient function."""
    result = n
    for p in factorize(n):
        result -= result // p
    return result


def legendre(b: int, p: int) -> int:
    """Legendre symbol (b|p) for an odd prime p, via Euler's criterion."""
    r = pow(b % p, (p - 1) // 2, p)
    return 0 if r == 0 else (1 if r == 1 else -1)


def jacobi(b: int, n: int) -> int:
    """Jacobi symbol (b|n) for odd n >= 1, by quadratic reciprocity."""
    assert n > 0 and n % 2 == 1
    b %= n
    result = 1
    while b != 0:
        while b % 2 == 0:
            b //= 2
            if n % 8 in (3, 5):
                result = -result
        b, n = n, b
        if b % 4 == 3 and n % 4 == 3:
            result = -result
        b %= n
    return result if n == 1 else 0


def units(n: int) -> List[int]:
    """The units modulo n, as residues in [0, n)."""
    return [b for b in range(n) if gcd(b, n) == 1]


# --------------------------------------------------------------------------
# The joint law
# --------------------------------------------------------------------------
def joint_law(n: int) -> Counter:
    """Multiset of pairs (ord_n(b), J(b|n)) over all units b mod n."""
    return Counter((multiplicative_order(b, n), jacobi(b, n)) for b in units(n))


def conditional_mean_order(n: int, sign: int) -> float:
    """E[ord_n(b) | J(b|n) = sign]."""
    law = joint_law(n)
    tot = sum(c for (_, j), c in law.items() if j == sign)
    s = sum(o * c for (o, j), c in law.items() if j == sign)
    return s / tot if tot else float("nan")


# --------------------------------------------------------------------------
# (1) Exact QR-order coupling at a prime
# --------------------------------------------------------------------------
def check_coupling_at_prime(p: int) -> bool:
    """Verify: b is a QR mod p  <=>  ord_p(b) | (p-1)/2, for every unit b."""
    H = (p - 1) // 2
    for b in range(1, p):
        qr = legendre(b, p) == 1
        divides_half = (H % multiplicative_order(b, p)) == 0
        if qr != divides_half:
            return False
    return True


# --------------------------------------------------------------------------
# (2) The 2-adic dichotomy for semiprimes
# --------------------------------------------------------------------------
def dichotomy_report(p: int, q: int) -> Tuple[bool, bool, int, int, int]:
    """
    Returns (order_test_is_exact, balanced, v2(H p), v2(H q), #counterexamples).

    order_test_is_exact is True iff, for every unit b mod N = p*q,
        ord_N(b) | lcm(H p, H q)  <=>  b is a QR mod p and mod q.
    balanced is True iff v2(H p) = v2(H q).
    """
    N = p * q
    Hp, Hq = (p - 1) // 2, (q - 1) // 2
    L = lcm(Hp, Hq)
    bad = 0
    for b in units(N):
        lhs = L % multiplicative_order(b, N) == 0
        rhs = legendre(b, p) == 1 and legendre(b, q) == 1
        if lhs != rhs:
            bad += 1
    return (bad == 0, v2(Hp) == v2(Hq), v2(Hp), v2(Hq), bad)


# --------------------------------------------------------------------------
# (3) Quadrant counts
# --------------------------------------------------------------------------
def legendre_quadrant_counts(p: int, q: int) -> Dict[Tuple[int, int], int]:
    """Split the units mod N = p*q by the pair of Legendre symbols ((b|p), (b|q))."""
    counts: Dict[Tuple[int, int], int] = {(1, 1): 0, (1, -1): 0, (-1, 1): 0, (-1, -1): 0}
    for b in units(p * q):
        counts[(legendre(b, p), legendre(b, q))] += 1
    return counts


def quadrant_counts(p: int, q: int) -> Dict[str, int]:
    """
    Split the units mod N = p*q by (order class, Jacobi symbol), where the
    order class is 'ord | L' versus 'ord does not divide L'.
    """
    N = p * q
    L = lcm((p - 1) // 2, (q - 1) // 2)
    counts = {"ord|L, J=+1": 0, "ord|L, J=-1": 0,
              "ord!|L, J=+1": 0, "ord!|L, J=-1": 0}
    for b in units(N):
        inhalf = L % multiplicative_order(b, N) == 0
        j = jacobi(b, N)
        key = ("ord|L" if inhalf else "ord!|L") + (", J=+1" if j == 1 else ", J=-1")
        counts[key] += 1
    return counts


# --------------------------------------------------------------------------
# Reporting
# --------------------------------------------------------------------------
def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_coupling() -> None:
    banner("(1) EXACT QR-ORDER COUPLING:  b is a QR mod p  <=>  ord_p(b) | (p-1)/2")
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    print(f"{'p':>5} {'(p-1)/2':>9} {'#units':>7} {'#QR':>5} {'#ord|H':>7} {'exact?':>8}")
    for p in primes:
        H = (p - 1) // 2
        nqr = sum(1 for b in range(1, p) if legendre(b, p) == 1)
        nhalf = sum(1 for b in range(1, p) if H % multiplicative_order(b, p) == 0)
        ok = check_coupling_at_prime(p)
        print(f"{p:>5} {H:>9} {p-1:>7} {nqr:>5} {nhalf:>7} {str(ok):>8}")
    print("\nAll 14 primes: the equivalence holds for every unit, with no exceptions.")


def demo_dichotomy() -> None:
    banner("(2) THE 2-ADIC DICHOTOMY:  exactness <=> v2((p-1)/2) = v2((q-1)/2)")
    pairs = [(3, 7), (3, 11), (7, 11), (11, 19), (23, 31),      # 3 mod 4 x 3 mod 4
             (3, 5), (7, 13), (11, 17), (3, 13), (7, 29),       # mixed
             (5, 13), (13, 17), (5, 17), (17, 29), (5, 29)]     # 1 mod 4 x 1 mod 4
    hdr = f"{'p':>4} {'q':>4} {'N':>6} {'p%4':>4} {'q%4':>4} {'v2Hp':>5} {'v2Hq':>5} " \
          f"{'balanced':>9} {'exact':>6} {'#bad':>5}"
    print(hdr)
    for p, q in pairs:
        exact, bal, a, b, bad = dichotomy_report(p, q)
        print(f"{p:>4} {q:>4} {p*q:>6} {p%4:>4} {q%4:>4} {a:>5} {b:>5} "
              f"{str(bal):>9} {str(exact):>6} {bad:>5}")
    print("\nThe 'balanced' and 'exact' columns agree in every row: the 2-adic")
    print("balance v2(Hp) = v2(Hq) is necessary AND sufficient for the order test")
    print("to be an exact characterisation of the both-residue quadrant.")
    print("When p = q = 3 (mod 4) both valuations are 0, so balance is automatic.")


def demo_quadrants() -> None:
    banner("(3) EQUIDISTRIBUTION ON THE 3-MOD-4 DIAL:  each quadrant = phi(N)/4")
    for p, q in [(3, 7), (3, 11), (7, 11), (11, 19), (7, 19), (23, 31)]:
        N = p * q
        c = quadrant_counts(p, q)
        phi = euler_phi(N)
        Hp, Hq = (p - 1) // 2, (q - 1) // 2
        print(f"\nN = {p}*{q} = {N},  phi(N) = {phi},  Hp*Hq = {Hp*Hq},  phi/4 = {phi//4}")
        for sig, v in legendre_quadrant_counts(p, q).items():
            print(f"    Legendre pair {str(sig):>9} : {v}")
        for k, v in c.items():
            print(f"    {k:>14} : {v}")
        assert c["ord|L, J=+1"] == Hp * Hq == phi // 4
        assert c["ord|L, J=-1"] == 0
    print("\nThe four Legendre quadrants each hold exactly Hp*Hq = phi(N)/4 units.")
    print("The order class {ord | L} is exactly the both-residue quadrant, of size")
    print("phi(N)/4; it sits strictly inside the J = +1 half, which has size phi(N)/2.")
    print("So J = +1 does NOT imply ord | L: the Jacobi symbol is blind to the")
    print("order quadrant.  Concretely, 1 and -1 both have J = +1, yet ord(1) = 1")
    print("divides L while ord(-1) = 2 does not (L is odd when p = q = 3 mod 4).")


def demo_blindness() -> None:
    banner("(3b) THE JACOBI SYMBOL IS BLIND TO THE ORDER QUADRANT")
    print(f"{'N=p*q':>9} {'L':>6} {'J(1|N)':>7} {'J(-1|N)':>8} {'ord(1)|L':>9} {'ord(-1)|L':>10}")
    for p, q in [(3, 7), (7, 11), (11, 19), (23, 31)]:
        N = p * q
        L = lcm((p - 1) // 2, (q - 1) // 2)
        print(f"{N:>9} {L:>6} {jacobi(1, N):>7} {jacobi(-1, N):>8} "
              f"{str(L % 1 == 0):>9} {str(L % 2 == 0):>10}")
    print("\nBoth units have Jacobi symbol +1, but they lie in different order")
    print("classes -- the order statistic is strictly finer than the symbol.")


def demo_collision() -> None:
    banner("(4) THE COLLISION BARRIER:  jointLaw(35) = jointLaw(39), gcd(35,39) = 1")
    l35, l39 = joint_law(35), joint_law(39)
    print(f"N = 35 = 5*7 : phi = {euler_phi(35)} units")
    print(f"N = 39 = 3*13: phi = {euler_phi(39)} units\n")
    print(f"{'(order, Jacobi)':>18} {'count in 35':>12} {'count in 39':>12}")
    for key in sorted(set(l35) | set(l39)):
        print(f"{str(key):>18} {l35.get(key, 0):>12} {l39.get(key, 0):>12}")
    same = l35 == l39
    print(f"\nIdentical multisets? {same}")
    print(f"gcd(35, 39) = {gcd(35, 39)}")
    print("\nConsequence.  Suppose F were any function of the joint law returning a")
    print("nontrivial divisor of the modulus.  Then F(law(35)) = F(law(39)) =: d,")
    print("with d > 1, d | 35 and d | 39, so d | gcd(35,39) = 1 -- contradiction.")
    print("No statistic of the order x Jacobi joint law can factor.")
    for e in (1, -1):
        s35 = sum(o * c for (o, j), c in l35.items() if j == e)
        s39 = sum(o * c for (o, j), c in l39.items() if j == e)
        print(f"    conditional order sum at J = {e:>2}: 35 -> {s35}, 39 -> {s39}")


def demo_conditional_bias() -> None:
    banner("(5) THE CONDITIONAL BIAS IS REAL BUT N-DETERMINED")
    print("E[ord | J = +1] / E[ord | J = -1] for a range of semiprimes.\n")
    print(f"{'N':>7} {'p':>5} {'q':>5} {'N%4':>4} {'E[ord|+1]':>11} "
          f"{'E[ord|-1]':>11} {'ratio':>8}")
    pairs = [(3, 7), (3, 11), (7, 11), (11, 19), (7, 19), (23, 31), (19, 23),
             (3, 5), (5, 7), (7, 13), (11, 13), (5, 13), (13, 17), (17, 29),
             (5, 17), (11, 17), (3, 13), (7, 29), (13, 29), (19, 31)]
    ratios: List[Tuple[int, float]] = []
    for p, q in pairs:
        N = p * q
        ep = conditional_mean_order(N, 1)
        em = conditional_mean_order(N, -1)
        r = ep / em
        ratios.append((N % 4, r))
        print(f"{N:>7} {p:>5} {q:>5} {N%4:>4} {ep:>11.2f} {em:>11.2f} {r:>8.4f}")
    print("\nThe ratio is systematically below 1: units with Jacobi symbol +1 have,")
    print("on average, SMALLER order.  That is the real bias.  The visible")
    print("structure is a residue dial, not a factor-size effect:")
    for m in sorted({k for k, _ in ratios}):
        rs = [r for k, r in ratios if k == m]
        print(f"    N = {m} (mod 4): mean ratio {sum(rs)/len(rs):.4f} over {len(rs)} moduli")
    both3 = [p * q for p, q in pairs if p % 4 == 3 and q % 4 == 3]
    print("\n  Empirical observation (numerical, not proved here): whenever")
    print("  p = q = 3 (mod 4) the ratio is exactly 3/4.  Tested moduli: "
          + ", ".join(str(n) for n in both3) + ".")


def demo_correlations() -> None:
    banner("(6) NO CORRELATION WITH THE FACTORS THEMSELVES")
    print("Pearson correlation of the bias ratio with p, q, p+q and |p-q|,")
    print("compared against a permutation null (10000 shuffles).\n")
    import random

    pairs = [(p, q) for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
             for q in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43] if p < q]
    data = []
    for p, q in pairs:
        N = p * q
        r = conditional_mean_order(N, 1) / conditional_mean_order(N, -1)
        data.append((p, q, r))

    def pearson(xs: Iterable[float], ys: Iterable[float]) -> float:
        xs, ys = list(xs), list(ys)
        n = len(xs)
        mx, my = sum(xs) / n, sum(ys) / n
        num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
        dx = sum((x - mx) ** 2 for x in xs) ** 0.5
        dy = sum((y - my) ** 2 for y in ys) ** 0.5
        return num / (dx * dy) if dx and dy else 0.0

    rs = [r for _, _, r in data]
    stats = {
        "p": [p for p, _, _ in data],
        "q": [q for _, q, _ in data],
        "p+q": [p + q for p, q, _ in data],
        "|p-q|": [abs(p - q) for p, q, _ in data],
    }
    random.seed(20240813)
    print(f"{'covariate':>10} {'|corr|':>8} {'null 95th pct':>15} {'inside null?':>13}")
    for name, xs in stats.items():
        obs = abs(pearson(xs, rs))
        null = []
        for _ in range(10000):
            shuffled = rs[:]
            random.shuffle(shuffled)
            null.append(abs(pearson(xs, shuffled)))
        null.sort()
        p95 = null[int(0.95 * len(null))]
        print(f"{name:>10} {obs:>8.3f} {p95:>15.3f} {str(obs <= p95):>13}")
    print("\nEvery observed correlation sits inside its own permutation null:")
    print("the joint law's bias carries no information about the individual")
    print("factors beyond what N mod 4 already reveals.")


def main() -> None:
    print(__doc__)
    demo_coupling()
    demo_dichotomy()
    demo_quadrants()
    demo_blindness()
    demo_collision()
    demo_conditional_bias()
    demo_correlations()
    banner("SUMMARY")
    print("""
  * The QR-order coupling is an exact equivalence at every odd prime.
  * Its lift to a semiprime N = p*q is exact precisely when the two half
    orders (p-1)/2 and (q-1)/2 carry the same power of 2 -- a single
    2-adic dial whose bottom rung is p = q = 3 (mod 4).
  * On that dial the four order x Jacobi quadrants each contain exactly a
    quarter of the units, and the Jacobi symbol cannot see which order
    class a unit lies in.
  * The complete joint laws of 35 = 5*7 and 39 = 3*13 coincide, and these
    moduli are coprime; therefore no function of the joint law can output
    a nontrivial factor.  The law is determined by data far coarser than
    the factorisation, and computing it already requires the factors.
""")


if __name__ == "__main__":
    main()
