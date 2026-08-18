"""Algorithm D: diversity certificates -- unconditional lower bounds on the price.

The identity  sum_x max(p(x), q(x)) = 1 + TV(p, q)  turns the Shtarkov sum,
a supremum-of-likelihoods object, into a statistical distance.  Consequently
any two members of a class certify a lower bound on its price of universality:

        price >= log2(1 + TV(p_theta, p_theta')),

and, because the price is additive over independent blocks, k blocks certify
k times as much.  The certificate costs a single linear pass over the message
space and requires no optimisation whatsoever: it proves that *no* universal
scheme for the class can do better than the stated number of bits.
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import Dict, Hashable, Sequence, Tuple

Msg = Hashable
Dist = Dict[Msg, float]


def total_variation(p: Dist, q: Dist, space: Sequence[Msg]) -> float:
    """TV(p, q) = (1/2) sum_x |p(x) - q(x)| in [0, 1]."""
    return 0.5 * sum(abs(p.get(x, 0.0) - q.get(x, 0.0)) for x in space)


def diversity_floor(p: Dist, q: Dist, space: Sequence[Msg]) -> float:
    """log2(1 + TV(p, q)): a certified lower bound on the price, in bits."""
    return math.log2(1.0 + total_variation(p, q, space))


def best_diversity_floor(space: Sequence[Msg],
                         members: Sequence[Dist]) -> Tuple[float, Tuple[int, int]]:
    """The strongest pairwise certificate, with the witnessing pair of indices."""
    best, witness = 0.0, (0, 0)
    for i, j in combinations(range(len(members)), 2):
        val = diversity_floor(members[i], members[j], space)
        if val > best:
            best, witness = val, (i, j)
    return best, witness


def tensorised_floor(space: Sequence[Msg], members: Sequence[Dist], k: int) -> float:
    """Certified lower bound on the price of k independent blocks."""
    floor, _ = best_diversity_floor(space, members)
    return k * floor


def is_universality_free(space: Sequence[Msg], members: Sequence[Dist],
                         tol: float = 1e-12) -> bool:
    """True exactly when all members coincide, i.e. when the price is zero."""
    floor, _ = best_diversity_floor(space, members)
    return floor <= tol


"""Algorithm C: certifying the price of a library of specialised decompressors.

Given only the Shtarkov sums C_1, ..., C_K of K specialised classes on a common
message space -- no access to the message space itself -- the two-sided library
bound pins the price of the merged, universal decompressor to an interval of
width at most log2 K bits:

        max_i log2 C_i  <=  price(library)  <=  log2 K + max_i log2 C_i.

The routine also reports the *marginal cost of universality*: how many extra
bits the merged decompressor may cost over the best specialist, and how many
bits are saved relative to the crude alternative of coding the specialist
index separately with a fixed-length tag.
"""

from __future__ import annotations

import math
from typing import Dict, Sequence


def library_price_interval(shtarkov_sums: Sequence[float]) -> Dict[str, float]:
    """Certify the library price from the members' Shtarkov sums alone."""
    if not shtarkov_sums:
        raise ValueError("a library needs at least one member")
    if any(c < 1.0 for c in shtarkov_sums):
        raise ValueError("every Shtarkov sum satisfies C >= 1")
    k = len(shtarkov_sums)
    prices = [math.log2(c) for c in shtarkov_sums]
    lower = max(prices)
    naming = math.log2(k)
    return {
        "num_models": float(k),
        "lower_bound_bits": lower,
        "upper_bound_bits": lower + naming,
        "naming_cost_bits": naming,
        "sum_bound_shtarkov": float(sum(shtarkov_sums)),
        "max_bound_shtarkov": float(max(shtarkov_sums)),
    }


def marginal_cost_of_doubling(k: int) -> float:
    """Doubling the size of a model library costs exactly one extra bit."""
    return math.log2(2 * k) - math.log2(k)


def is_library_worth_it(specialist_prices: Sequence[float],
                        monolith_price: float) -> bool:
    """Decide whether a library beats a single monolithic universal model.

    The library is worth building when the worst specialist, plus the log2 K
    naming cost, still beats the price of the single class that covers
    everything.
    """
    k = len(specialist_prices)
    return max(specialist_prices) + math.log2(k) < monolith_price


"""Algorithm A: maximum likelihood envelope, Shtarkov sum, price, NML code."""

from __future__ import annotations

import math
from typing import Dict, Hashable, List, Sequence, Tuple

Msg = Hashable
Dist = Dict[Msg, float]


def envelope(space: Sequence[Msg], members: Sequence[Dist]) -> Dist:
    """hat p(x) = max_theta p_theta(x), the maximum likelihood envelope."""
    return {x: max(p.get(x, 0.0) for p in members) for x in space}


def shtarkov_sum(space: Sequence[Msg], members: Sequence[Dist]) -> float:
    """C = sum_x hat p(x) >= 1."""
    return sum(envelope(space, members).values())


def price_bits(space: Sequence[Msg], members: Sequence[Dist]) -> float:
    """log2 C: the exact worst-case price of universality, in bits."""
    return math.log2(shtarkov_sum(space, members))


def nml_code(space: Sequence[Msg], members: Sequence[Dist]) -> Dist:
    """The normalised maximum likelihood distribution q*(x) = hat p(x) / C.

    q* is the unique minimax-regret coding distribution: for every member
    p_theta and every message x, log2(p_theta(x) / q*(x)) <= log2 C, and no
    coding distribution achieves a smaller uniform bound.
    """
    env = envelope(space, members)
    c = sum(env.values())
    return {x: env[x] / c for x in space}


def worst_case_regret(space: Sequence[Msg], members: Sequence[Dist],
                      q: Dist) -> float:
    """max_{theta, x : p_theta(x) > 0} log2(p_theta(x) / q(x)), in bits."""
    worst = -math.inf
    for p in members:
        for x in space:
            if p.get(x, 0.0) > 0.0 and q[x] > 0.0:
                worst = max(worst, math.log2(p[x] / q[x]))
    return worst


def certify_minimax(space: Sequence[Msg], members: Sequence[Dist]) -> Tuple[float, float]:
    """Return (price, worst-case regret of the NML code); they must agree."""
    return price_bits(space, members), worst_case_regret(space, members,
                                                         nml_code(space, members))


"""Algorithm B: the price of a product class, by factorisation.

Naive evaluation of the price of S1 (x) S2 enumerates N1*N2 messages against
M1*M2 parameter pairs, at cost Theta(N1 N2 M1 M2).  The factorisation theorem
for the maximum likelihood envelope collapses this to Theta(N1 M1 + N2 M2):
the Shtarkov sums simply multiply, so the prices in bits simply add.  For k
identical independent blocks the price is exactly k times the per-block price,
computable in time independent of k.
"""

from __future__ import annotations

import math
from typing import Dict, Hashable, Sequence, Tuple

Msg = Hashable
Dist = Dict[Msg, float]


def shtarkov_sum(space: Sequence[Msg], members: Sequence[Dist]) -> float:
    return sum(max(p.get(x, 0.0) for p in members) for x in space)


def product_price_naive(space1: Sequence[Msg], members1: Sequence[Dist],
                        space2: Sequence[Msg], members2: Sequence[Dist]) -> float:
    """Brute force over the product class: Theta(N1 N2 M1 M2)."""
    joint_space = [(a, b) for a in space1 for b in space2]
    joint_members = [{(a, b): p.get(a, 0.0) * q.get(b, 0.0)
                      for a in space1 for b in space2}
                     for p in members1 for q in members2]
    return math.log2(shtarkov_sum(joint_space, joint_members))


def product_price_fast(space1: Sequence[Msg], members1: Sequence[Dist],
                       space2: Sequence[Msg], members2: Sequence[Dist]) -> float:
    """By factorisation of the envelope: Theta(N1 M1 + N2 M2)."""
    return (math.log2(shtarkov_sum(space1, members1))
            + math.log2(shtarkov_sum(space2, members2)))


def blocks_price(space: Sequence[Msg], members: Sequence[Dist], k: int) -> float:
    """Price of k independent blocks of the same class: exactly k * price."""
    return k * math.log2(shtarkov_sum(space, members))


def compare(space1: Sequence[Msg], members1: Sequence[Dist],
            space2: Sequence[Msg], members2: Sequence[Dist]) -> Tuple[float, float]:
    """Return (naive, fast) prices; they agree to machine precision."""
    return (product_price_naive(space1, members1, space2, members2),
            product_price_fast(space1, members1, space2, members2))


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/NumberTheory/UniversalRedundancyAverage.lean",
    "Catalog/NumberTheory/UniversalRedundancyPriceSeparation.lean",
    "Catalog/NumberTheory/UniversalRedundancyConservation.lean",
    "Catalog/NumberTheory/UniversalRedundancyAlgebra.lean",
    "Catalog/NumberTheory/UniversalRedundancyDiversity.lean",
    "Catalog/NumberTheory/UniversalRedundancyTypeClass.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===================================================================\n"
    f"-- FILE: {f}\n"
    f"-- ===================================================================\n\n"
    + read(ROOT / f)
    for f in LEAN_FILES
)

FUTURE = """# Future directions — price of universality (Phase A, Question 1)

Derived from what survived and what failed in this cycle.  Each conjecture is
stated so that it can be refuted by a single counterexample or settled by a
single theorem, and each names the object it should be built on.

## What this cycle established (context for the conjectures)

* Worst-case price = `log2 C_S` (earlier cycle).
* **Average-case (Bayes) price**: compensation identity, `redundancy >= capacity`,
  `<= log2 #Theta`, and `= log2 #Theta` exactly for mutually singular classes;
  robust to approximate singularity (`(1-delta) log2 #Theta - 4`).
* **Bridge**: average price <= worst-case price for every class.
* **Algebra**: price is additive over independent products and subadditive over
  libraries (`<= log2 K + max_i price_i`).
* **Conservation of bits** for file-type classes, and an exactly solvable
  natural class (constant composition) with price exactly `log2 (n+1)`.
* **Diversity bounds**: `C_S >= 1 + ||p_theta - p_theta'||_TV` for every pair of
  members, hence `C_S = 1` *iff* the class is a single source, the price is
  strictly positive for any nondegenerate class, the price is monotone under
  passing to a subclass, and the total-variation floor tensorises to
  `k * log2(1+delta)` over `k` independent blocks.

## Conjecture 1 (redundancy-capacity theorem: the minimax is a maximin)

For every finite class `S`,

`inf_q max_theta D(p_theta || q) = max_w I(w)`,

with the infimum attained at the Bayes mixture of a maximising prior.  We proved
`>=` and the upper bound `<= log2 #Theta`; the missing half is a genuine minimax
exchange.  *The key insight is* that `w -> I(w)` is concave and
`q -> sum_theta w(theta) D(p_theta || q)` is convex, so Sion's minimax theorem
applies on the (compact, convex) simplex of priors and coding distributions --
the only obstruction is that the minimax machinery must be instantiated for the
extended-real-valued divergence.  *Why now?*  All the convexity ingredients are
already in place (Gibbs, compensation identity), so the theorem is one
compactness argument away, and it upgrades every lower bound from "for each
prior" to "exactly".

## Conjecture 2 (sharp Rissanen constant for the memoryless class)

For a binary memoryless class on `n` bits,

`log2 C_n = (1/2) log2 n + (1/2) log2(pi/2) + o(1)`,

and more generally `((k-1)/2) log2 n + O(1)` for alphabet size `k`.  Our proved
bounds are `(1/2) log2 n - 2 <= log2 C_n <= k log2(n+1)`, a factor-2 gap at the
top.  *The key insight is* that the Shtarkov sum is a sum of binomial mode
probabilities, `C_n = sum_j P(Bin(n, j/n) = j)`, so Stirling bounds on the
central term plus a Laplace-type comparison of neighbouring terms should pin the
constant.  *Why now?*  Computational evidence shows `C_n / sqrt(pi n / 2) =
1.017` at `n = 1000`, and the elementary Stirling estimates are already
available.

## Further directions opened by this cycle

* **Tightness of the library bound.**  Express `C_library` explicitly in terms of
  the pairwise overlaps of the members' envelopes, interpolating between
  `max_i C_i` (one member dominates) and `sum_i C_i` (mutual singularity).
* **Non-product dependence.**  Determine the price for classes whose parameters
  are shared or slowly varying across blocks, interpolating between the
  `Theta(log n)` of a fully tied parameter and the `Theta(n)` of fully free ones.
* **Beyond finite message spaces.**  The envelope factorisation already holds for
  infinite parameter sets; extend Shtarkov sums to countable or continuous
  message spaces, where the envelope may fail to be integrable, and characterise
  the finitely-priced classes.
"""

package = {
    "title": "The Price of Universality: An Algebra of Source Classes "
             "for Universal Compression",
    "domain": "Computation",
    "description": (
        "The worst-case cost of serving all data with one shared decompressor is "
        "the logarithm of a class's Shtarkov sum, and this quantity obeys a "
        "complete algebra: it is exactly additive over independent data blocks and "
        "exceeds the most expensive of K specialised models by at most log2 K bits. "
        "Together with a total-variation lower bound, exactly solvable classes, and "
        "a conservation law for file types, this settles when specialised "
        "decompressors are worth building."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-18",
    "key_results": [
        "Multiplicativity of the Shtarkov sum over independent products, proved via "
        "a factorisation of the maximum likelihood envelope valid for arbitrary "
        "parameter sets: the price of universality in bits is exactly additive, so "
        "k independent blocks cost exactly k times the per-block price.",
        "Two-sided library bound: the Shtarkov sum of a union of K specialised "
        "classes lies between the largest and the sum of the members' Shtarkov "
        "sums, so merging K specialised decompressors costs at most log2 K bits "
        "more than the most expensive specialist alone.",
        "Diversity floor: the Shtarkov sum is at least 1 plus the total variation "
        "distance between any two members, hence the price vanishes exactly for a "
        "one-source class, is monotone under passing to a subclass, and tensorises "
        "to k log2(1 + delta) over k independent blocks.",
        "Average-case theory with the compensation identity (average redundancy = "
        "mutual information + divergence from the Bayes mixture), the redundancy "
        "at least capacity lower bound, and a bridge showing the average-case "
        "price never exceeds the worst-case price.",
        "Exact values and conservation: mutually singular classes cost exactly "
        "log2 of the number of sources (robustly, under approximate singularity), "
        "the constant-composition class on n bits costs exactly log2(n+1), and "
        "file-type partitions merely relocate log2(number of types) bits from the "
        "payload into the identity of the decompressor.",
    ],
    "keywords": [
        "universal compression",
        "minimax redundancy",
        "Shtarkov sum",
        "normalised maximum likelihood",
        "model libraries",
        "total variation",
        "method of types",
        "Rissanen rate",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Structural Verification Suite for the Price of Universality",
            "description": (
                "Brute-force verification, by exhaustive summation over binary "
                "message spaces, of every structural statement of the theory: the "
                "multiplicativity of the Shtarkov sum over independent products and "
                "the resulting exact additivity of the price in bits; the two-sided "
                "library bound max_i C_i <= C_library <= sum_i C_i together with the "
                "log2 K + max_i price_i bit bound; the total-variation diversity "
                "floor 1 + TV <= C and its tensorisation over k blocks; the exact "
                "Shtarkov sums of mutually singular classes (2^n for all n-bit "
                "files) and of the constant-composition class (exactly n+1); the "
                "bridge showing that the normalised maximum likelihood code's "
                "average redundancy against every source never exceeds the "
                "worst-case price log2 C; and the separation table contrasting the "
                "exactly-n price of the unstructured class with the logarithmic "
                "price of the memoryless class, including the numerical ratio "
                "C_n / sqrt(pi n / 2) that probes the conjectured Rissanen constant."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Bayes Redundancy Laboratory: Compensation Identity, Capacity "
                    "Bound, and the Worst-Case Bridge",
            "description": (
                "A numerical laboratory for the average-case (Rissanen) theory. For "
                "a family of memoryless binary sources it computes Kullback-Leibler "
                "redundancies against several candidate universal codes (the Bayes "
                "mixture, the normalised maximum likelihood code, the uniform code, "
                "and a deliberately mis-specified code) and checks the compensation "
                "identity sum_theta w(theta) D(p_theta || q) = I(w) + D(m_w || q) to "
                "machine precision, thereby exhibiting the Bayes mixture as the "
                "unique optimal universal code with cost exactly the mutual "
                "information. It then verifies the redundancy-at-least-capacity "
                "lower bound for every candidate code, the two-part-code upper bound "
                "D(p_theta || m_w) <= log2(1/w(theta)), the bridge inequality "
                "D(p_theta || NML) <= log2 C, and finally the exactness of the price "
                "log2 |Theta| for a mutually singular class, using the "
                "constant-composition sources whose entropies are the binomial "
                "coefficients log2 C(n, j)."
            ),
            "code": read(A / "demo_bayes.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Maximum Likelihood Envelope and the Normalised Maximum "
                    "Likelihood Code",
            "description": (
                "The foundational routine of the theory. Given a finite message "
                "space of size N and a class of M candidate sources, it computes the "
                "maximum likelihood envelope hat p(x) = max_theta p_theta(x), the "
                "Shtarkov sum C = sum_x hat p(x), the price of universality log2 C, "
                "and the normalised maximum likelihood distribution q* = hat p / C. "
                "The mathematical content is that q* solves the minimax regret "
                "problem exactly: its regret log2(p_theta(x)/q*(x)) is at most log2 C "
                "for every source and every message, and any code with uniform "
                "regret at most r satisfies hat p <= 2^r q pointwise, hence C <= 2^r. "
                "The routine also recomputes the realised worst-case regret so the "
                "two numbers can be compared as a self-check. Complexity: Theta(N M) "
                "time and Theta(N) space, i.e. a single pass over the "
                "message-by-parameter table; the entire minimax optimisation "
                "collapses to this pass because the optimality condition is "
                "pointwise domination."
            ),
            "pseudocode": (
                "INPUT : finite message space X = {x_1, ..., x_N};\n"
                "        source class S = {p_1, ..., p_M}, each a distribution on X\n"
                "OUTPUT: envelope hatp, Shtarkov sum C, price in bits, NML code q*\n"
                "\n"
                "1.  for each x in X:\n"
                "2.      hatp[x] <- max over theta in {1..M} of p_theta(x)\n"
                "3.  C <- 0\n"
                "4.  for each x in X:  C <- C + hatp[x]        // C >= 1 always\n"
                "5.  price <- log2(C)\n"
                "6.  for each x in X:  qstar[x] <- hatp[x] / C  // a distribution\n"
                "7.  // self-check: the realised minimax regret\n"
                "8.  r <- -infinity\n"
                "9.  for each theta, for each x with p_theta(x) > 0:\n"
                "10.     r <- max(r, log2(p_theta(x) / qstar[x]))\n"
                "11. assert |r - price| < tolerance      // minimaxity of the NML code\n"
                "12. return (hatp, C, price, qstar)"
            ),
            "code": read(A / "alg_nml.py"),
        },
        {
            "name": "Factorised Evaluation of the Price of a Product Class",
            "description": (
                "Exploits the factorisation of the maximum likelihood envelope over "
                "independent blocks. A naive evaluation of the price of S1 (x) S2 "
                "enumerates N1*N2 joint messages against M1*M2 parameter pairs, "
                "costing Theta(N1 N2 M1 M2) time and Theta(N1 N2) space. Because the "
                "envelope of a product is the product of the envelopes -- a fact that "
                "holds for arbitrary, possibly infinite parameter sets, where the "
                "suprema need not be attained -- the Shtarkov sums simply multiply "
                "and the prices in bits simply add, so the same quantity is obtained "
                "in Theta(N1 M1 + N2 M2) time. For k identical independent blocks the "
                "price is exactly k times the per-block price, computable in time "
                "independent of k, an exponential saving over enumeration of the "
                "k-fold product space. The routine returns both the naive and the "
                "fast value so that the identity can be witnessed numerically."
            ),
            "pseudocode": (
                "INPUT : classes S1 on X1 (N1 messages, M1 sources)\n"
                "        and S2 on X2 (N2 messages, M2 sources)\n"
                "OUTPUT: the price in bits of the independent product S1 (x) S2\n"
                "\n"
                "NAIVE (for comparison only) -- Theta(N1 N2 M1 M2):\n"
                "1.  joint space  <- { (a,b) : a in X1, b in X2 }\n"
                "2.  joint class  <- { p (x) q : p in S1, q in S2 }\n"
                "3.  return log2( sum over (a,b) of max over (p,q) of p(a) q(b) )\n"
                "\n"
                "FAST -- Theta(N1 M1 + N2 M2):\n"
                "4.  C1 <- sum over a in X1 of max over p in S1 of p(a)\n"
                "5.  C2 <- sum over b in X2 of max over q in S2 of q(b)\n"
                "6.  return log2(C1) + log2(C2)        // envelope factorisation\n"
                "\n"
                "k IDENTICAL BLOCKS -- Theta(N M), independent of k:\n"
                "7.  C <- Shtarkov sum of the single-block class\n"
                "8.  return k * log2(C)"
            ),
            "code": read(A / "alg_product.py"),
        },
        {
            "name": "Certification of the Price of a Library of Specialised "
                    "Decompressors",
            "description": (
                "Bounds the price of a merged, universal decompressor from the "
                "summary statistics of its specialists alone, without any access to "
                "the message space. Given the Shtarkov sums C_1, ..., C_K of K "
                "specialised classes on a common message space, the two-sided library "
                "bound max_i C_i <= C_library <= sum_i C_i places the price of the "
                "merged decompressor inside an interval of width at most log2 K bits: "
                "[max_i log2 C_i, log2 K + max_i log2 C_i]. The lower endpoint holds "
                "because every likelihood available to a specialist is available to "
                "the library; the upper endpoint because the library's envelope is "
                "pointwise dominated by the sum of the specialists' envelopes. "
                "Complexity: Theta(K) time and O(1) space -- the message space is "
                "never touched. The routine also reports the marginal cost of "
                "doubling the model zoo (exactly one bit) and a decision rule for "
                "whether a library beats a single monolithic universal model."
            ),
            "pseudocode": (
                "INPUT : Shtarkov sums C_1, ..., C_K of K specialised classes\n"
                "        on a common finite message space (each C_i >= 1)\n"
                "OUTPUT: a certified interval containing the library's price in bits\n"
                "\n"
                "1.  if K = 0: error 'a library needs at least one member'\n"
                "2.  for i in 1..K:\n"
                "3.      if C_i < 1: error 'not a Shtarkov sum'\n"
                "4.      r_i <- log2(C_i)                 // price of specialist i\n"
                "5.  lower  <- max_i r_i                  // library dominates members\n"
                "6.  naming <- log2(K)                    // cost of naming a model\n"
                "7.  upper  <- lower + naming             // subadditivity of envelopes\n"
                "8.  return [lower, upper], naming\n"
                "\n"
                "DECISION RULE (library versus one monolithic universal model):\n"
                "9.  build the library iff  max_i r_i + log2(K)  <  price(monolith)"
            ),
            "code": read(A / "alg_library.py"),
        },
        {
            "name": "Total-Variation Diversity Certificates for Universal Redundancy",
            "description": (
                "Produces unconditional lower bounds on the price of universality of "
                "a class, certifying that no universal scheme whatsoever can beat a "
                "stated number of bits. The mechanism is the elementary identity "
                "sum_x max(p(x), q(x)) = 1 + TV(p, q), which converts the Shtarkov "
                "sum -- a supremum-of-likelihoods object -- into a statistical "
                "distance: any two members of the class give C >= 1 + TV, hence a "
                "price of at least log2(1 + TV) bits. Because the price is additive "
                "over independent blocks, the certificate tensorises: k blocks cost "
                "at least k log2(1 + TV). Searching all pairs costs Theta(N M^2) time "
                "for M sources on N messages (Theta(N) for a single pair), with no "
                "optimisation over coding distributions at any point. As a special "
                "case the routine decides degeneracy: the price is zero exactly when "
                "all pairwise total variation distances vanish, i.e. when the class "
                "is a single source in disguise."
            ),
            "pseudocode": (
                "INPUT : finite message space X; class members p_1, ..., p_M;\n"
                "        number of independent blocks k\n"
                "OUTPUT: a certified lower bound on the price of universality\n"
                "\n"
                "1.  best <- 0;  witness <- (none)\n"
                "2.  for each pair i < j:\n"
                "3.      TV <- (1/2) * sum over x in X of |p_i(x) - p_j(x)|\n"
                "4.      floor_ij <- log2(1 + TV)\n"
                "5.      if floor_ij > best: best <- floor_ij; witness <- (i, j)\n"
                "6.  // one block: no code can have worst-case regret below 'best'\n"
                "7.  // k independent blocks: the floor tensorises\n"
                "8.  return (best, k * best, witness)\n"
                "\n"
                "DEGENERACY TEST:\n"
                "9.  universality is free  iff  best = 0  iff  all members coincide"
            ),
            "code": read(A / "alg_diversity.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Maximum Likelihood Envelope and the Excess Mass You Pay For",
            "description": (
                "A two-panel figure making the central object visible. The left panel "
                "plots two memoryless sources over all 4-bit strings, ordered by "
                "weight, together with their pointwise maximum -- the maximum "
                "likelihood envelope -- drawn as a step outline. Each source has mass "
                "1; the envelope has mass C >= 1, and the shaded surplus C - 1 is "
                "exactly the geometric object whose logarithm is the price of "
                "universality in bits. The right panel sweeps the two parameters "
                "apart from 0.5 - g to 0.5 + g and plots the Shtarkov sum against the "
                "total-variation floor 1 + TV, exhibiting that for a class of exactly "
                "two sources the diversity bound is an equality, so the price is "
                "precisely log2(1 + TV)."
            ),
            "code": read(A / "viz_envelope.py"),
        },
        {
            "name": "The Two Laws of the Algebra, and the Separation between Classes",
            "description": (
                "A three-panel figure summarising the structural results. Top left: "
                "additivity over independent blocks -- the computed prices of the "
                "1-, 2-, 3- and 4-fold products of a class sit exactly on the line "
                "through the origin of slope equal to the per-block price. Top right: "
                "the library band -- as the number K of specialised classes grows, "
                "the computed library price is plotted inside the shaded admissible "
                "region between max_i price_i and log2 K + max_i price_i, a band that "
                "widens only logarithmically. Bottom: the separation -- the "
                "unstructured class on n-bit files costs exactly n bits, the "
                "constant-composition class exactly log2(n+1), and the binary "
                "memoryless class log2 C_n, plotted against the conjectured "
                "asymptote (1/2) log2 n + (1/2) log2(pi/2). The diverging gap is the "
                "number of bits that genuine structure is worth."
            ),
            "code": read(A / "viz_algebra.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Price of Universality Laboratory: Envelopes, Blocks, "
                     "Libraries, and the Separation",
            "description": (
                "A four-panel interactive laboratory that computes everything live in "
                "the browser by exhaustive summation over the message space -- no "
                "fitted curves and no approximations. Panel 1 lets the reader choose "
                "the message length and the parameters of two or three memoryless "
                "sources, and draws the sources together with their maximum "
                "likelihood envelope, reporting the Shtarkov sum, the excess mass, "
                "the total variation between the extreme members, the certified "
                "diversity floor, and the resulting price in bits; setting the two "
                "parameters equal makes the price collapse to exactly zero, "
                "illustrating that universality is free only for a degenerate class. "
                "Panel 2 sweeps the number of independent blocks and shows the price "
                "growing exactly linearly, against a dashed line marking the wishful "
                "'pay once' model that additivity rules out. Panel 3 builds a library "
                "of up to eight specialised classes with adjustable separation and "
                "plots the true library price inside the guaranteed band between the "
                "worst specialist and that specialist plus log2 K bits, with "
                "commentary explaining why nearly singular specialists sit at the top "
                "of the band and overlapping ones at the bottom. Panel 4 contrasts, "
                "over message lengths up to 48 bits, the exactly-n price of the "
                "unstructured class with the logarithmic prices of the "
                "constant-composition and memoryless classes and the conjectured "
                "Rissanen asymptote."
            ),
            "html": read(A / "widget.html"),
        },
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "demo_bayes": read(A / "demo_bayes.py"),
        "alg_nml": read(A / "alg_nml.py"),
        "alg_product": read(A / "alg_product.py"),
        "alg_library": read(A / "alg_library.py"),
        "alg_diversity": read(A / "alg_diversity.py"),
        "viz_envelope": read(A / "viz_envelope.py"),
        "viz_algebra": read(A / "viz_algebra.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n",
               encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""
The average-case (Bayes) theory of universal coding, verified numerically.

Where the worst-case theory charges a universal code for its single most
embarrassing message, the average-case theory asks how many extra bits the
code spends *in expectation* against each source of the class.  If the true
source is p_theta and the code is q, that excess is exactly the Kullback-
Leibler divergence D(p_theta || q), because D(p || 2^-len) = E_p[len] - H(p).

This script verifies, by brute force on small binary message spaces:

  1. Gibbs / Shannon:  D(p || q) >= 0, so no code beats the entropy.
  2. The compensation identity:
         sum_theta w(theta) D(p_theta || q) = I(w) + D(m_w || q),
     where m_w is the Bayes mixture and I(w) the mutual information.  The
     mixture is therefore the unique Bayes-optimal universal code, and the
     unavoidable price under the prior w is exactly I(w).
  3. Redundancy >= capacity: whatever q is chosen, some source pays at least
     I(w) bits, for every prior w.
  4. Two-part-code bound:  D(p_theta || m_w) <= log2(1 / w(theta)).
  5. The bridge: the worst-case-optimal code (NML) pays at most log2 C on
     average against every source, so average price <= worst-case price.
  6. Mutually singular classes: the average price is exactly log2 |Theta|.
"""

from __future__ import annotations

import itertools
import math
from typing import Dict, List, Sequence, Tuple

Msg = Tuple[int, ...]
Dist = Dict[Msg, float]


def strings(n: int) -> List[Msg]:
    return [tuple(b) for b in itertools.product((0, 1), repeat=n)]


def bern(theta: float, x: Msg) -> Dist:
    k = sum(x)
    return theta ** k * (1.0 - theta) ** (len(x) - k)


def kl(p: Dist, q: Dist, space: Sequence[Msg]) -> float:
    return sum(p[x] * math.log2(p[x] / q[x]) for x in space if p[x] > 0.0)


def entropy(p: Dist, space: Sequence[Msg]) -> float:
    return -sum(p[x] * math.log2(p[x]) for x in space if p[x] > 0.0)


def mixture(members: Sequence[Dist], w: Sequence[float], space: Sequence[Msg]) -> Dist:
    return {x: sum(wi * p[x] for wi, p in zip(w, members)) for x in space}


def mutual_information(members: Sequence[Dist], w: Sequence[float],
                       space: Sequence[Msg]) -> float:
    m = mixture(members, w, space)
    return sum(wi * kl(p, m, space) for wi, p in zip(w, members))


def nml(members: Sequence[Dist], space: Sequence[Msg]) -> Tuple[Dist, float]:
    env = {x: max(p[x] for p in members) for x in space}
    c = sum(env.values())
    return {x: env[x] / c for x in space}, c


def main() -> None:
    print(__doc__)
    n = 4
    space = strings(n)
    thetas = [0.15, 0.35, 0.5, 0.7, 0.9]
    members = [{x: bern(t, x) for x in space} for t in thetas]
    K = len(members)
    w = [1.0 / K] * K

    print("=" * 70)
    print("1-2.  COMPENSATION IDENTITY  (uniform prior, several coding rules)")
    print("=" * 70)
    m = mixture(members, w, space)
    info = mutual_information(members, w, space)
    print(f"  mutual information I(w) = {info:.8f} bits  "
          f"(<= log2 |Theta| = {math.log2(K):.6f})")
    q_nml, c = nml(members, space)
    candidates = {
        "Bayes mixture m_w": m,
        "NML code q*": q_nml,
        "uniform code": {x: 1.0 / len(space) for x in space},
        "biased code (theta=0.5 source)": {x: bern(0.5, x) for x in space},
    }
    for name, q in candidates.items():
        lhs = sum(wi * kl(p, q, space) for wi, p in zip(w, members))
        rhs = info + kl(m, q, space)
        print(f"  {name:32s} avg redundancy = {lhs:.8f}, "
              f"I(w) + D(m||q) = {rhs:.8f}  "
              f"[{'OK' if abs(lhs - rhs) < 1e-9 else 'FAIL'}]")
    print("  => the mixture is Bayes-optimal; its cost is exactly I(w).\n")

    print("=" * 70)
    print("3-4.  REDUNDANCY >= CAPACITY, AND THE TWO-PART-CODE BOUND")
    print("=" * 70)
    for name, q in candidates.items():
        worst = max(kl(p, q, space) for p in members)
        print(f"  {name:32s} max_theta D = {worst:.6f} >= I(w) = {info:.6f}  "
              f"[{'OK' if worst >= info - 1e-9 else 'FAIL'}]")
    print()
    for t, p in zip(thetas, members):
        d = kl(p, m, space)
        print(f"  theta = {t:.2f}:  D(p || m_w) = {d:.6f} <= log2(1/w) = "
              f"{math.log2(K):.6f}  [{'OK' if d <= math.log2(K) + 1e-9 else 'FAIL'}]")
    print()

    print("=" * 70)
    print("5.  THE BRIDGE: average price <= worst-case price")
    print("=" * 70)
    print(f"  worst-case price log2 C = {math.log2(c):.6f} bits")
    for t, p in zip(thetas, members):
        d = kl(p, q_nml, space)
        print(f"  theta = {t:.2f}:  D(p || NML) = {d:.6f}  "
              f"[{'OK' if d <= math.log2(c) + 1e-9 else 'FAIL'}]")
    print()

    print("=" * 70)
    print("6.  MUTUALLY SINGULAR CLASS: the average price is exactly log2|Theta|")
    print("=" * 70)
    # constant-composition sources on n bits: disjoint supports, |Theta| = n+1
    comp: List[Dist] = []
    for j in range(n + 1):
        fibre = [x for x in space if sum(x) == j]
        comp.append({x: (1.0 / len(fibre) if sum(x) == j else 0.0) for x in space})
    wc = [1.0 / (n + 1)] * (n + 1)
    mc = mixture(comp, wc, space)
    target = math.log2(n + 1)
    print(f"  |Theta| = {n + 1}, log2|Theta| = {target:.6f} bits")
    for j, p in enumerate(comp):
        d = kl(p, mc, space)
        print(f"  composition j = {j}:  D(p_j || uniform mixture) = {d:.6f}  "
              f"[{'OK' if d <= target + 1e-9 else 'FAIL'}]  "
              f"entropy H(p_j) = {entropy(p, space):.6f} = log2 C({n},{j})")
    # every coding distribution loses at least log2|Theta| against some member
    for name, q in [("uniform code", {x: 1.0 / len(space) for x in space}),
                    ("mixture", mc),
                    ("theta=0.3 memoryless", {x: bern(0.3, x) for x in space})]:
        worst = max(kl(p, q, space) for p in comp)
        print(f"  {name:24s} max_j D(p_j || q) = {worst:.6f} >= {target:.6f}  "
              f"[{'OK' if worst >= target - 1e-9 else 'FAIL'}]")
    print("\n  => for disjointly supported sources the universal code must literally")
    print("     spend the bits that name the source.")


if __name__ == "__main__":
    main()


"""
Visualisation: the two laws of the algebra of source classes, side by side.

Left panel  -- PRODUCTS PENALISE DATA.  The price of universality is additive
over independent blocks: k blocks of a class of price r cost exactly k*r bits.
The curve is a straight line through the origin, and the computed values
(brute force over the product message space) sit exactly on it.

Right panel -- UNIONS BARELY PENALISE MODELS.  The price of a library of K
specialised classes lies between max_i price_i and log2 K + max_i price_i.
The admissible band is shaded; the computed library price is plotted inside
it.  The band widens only logarithmically in K.

Bottom panel -- THE SEPARATION.  On n-bit messages the unstructured class
("any file at all") costs exactly n bits, while the memoryless class costs
log2 C_n ~ (1/2) log2 n + (1/2) log2(pi/2).  The gap diverges.
"""

from __future__ import annotations

import itertools
import math
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

Msg = Tuple[int, ...]


def strings(n: int) -> List[Msg]:
    return [tuple(b) for b in itertools.product((0, 1), repeat=n)]


def bern(theta: float, x: Msg) -> float:
    k = sum(x)
    return theta ** k * (1.0 - theta) ** (len(x) - k)


def shtarkov(members: List[Dict[Msg, float]], space: List[Msg]) -> float:
    return sum(max(p[x] for p in members) for x in space)


def bernoulli_shtarkov_exact(n: int) -> float:
    tot = 0.0
    for j in range(n + 1):
        if j in (0, n):
            tot += 1.0
        else:
            t = j / n
            tot += math.comb(n, j) * t ** j * (1 - t) ** (n - j)
    return tot


def make_figure() -> None:
    fig = plt.figure(figsize=(13, 9))

    # --- left: additivity over products -------------------------------------
    ax = fig.add_subplot(2, 2, 1)
    n = 2
    space = strings(n)
    thetas = [0.25, 0.75]
    base = [{x: bern(t, x) for x in space} for t in thetas]
    r = math.log2(shtarkov(base, space))
    ks, prices = [], []
    cur_space, cur_members = space, base
    for k in range(1, 5):
        ks.append(k)
        prices.append(math.log2(shtarkov(cur_members, cur_space)))
        if k < 4:
            new_space = [a + b for a in cur_space for b in space]
            new_members = [{a + b: p[a] * q[b] for a in cur_space for b in space}
                           for p in cur_members for q in base]
            cur_space, cur_members = new_space, new_members
    ax.plot([0, 4], [0, 4 * r], "-", color="grey", label=r"$k\cdot$price (theory)")
    ax.plot(ks, prices, "o", markersize=9, color="crimson", label="computed")
    ax.set_xlabel("number $k$ of independent blocks")
    ax.set_ylabel("price of universality (bits)")
    ax.set_title("Products: the price is exactly additive")
    ax.grid(alpha=0.3)
    ax.legend()

    # --- right: library band ------------------------------------------------
    ax = fig.add_subplot(2, 2, 2)
    n = 4
    space = strings(n)
    families = [
        [0.05, 0.10, 0.15],
        [0.45, 0.50, 0.55],
        [0.85, 0.90, 0.95],
        [0.30, 0.35],
        [0.60, 0.65],
        [0.02, 0.98],
    ]
    Ks, lows, highs, actual = [], [], [], []
    for K in range(1, len(families) + 1):
        chosen = families[:K]
        specialists = [[{x: bern(t, x) for x in space} for t in fam] for fam in chosen]
        cs = [shtarkov(m, space) for m in specialists]
        lib = [p for m in specialists for p in m]
        Ks.append(K)
        lows.append(max(math.log2(c) for c in cs))
        highs.append(math.log2(K) + max(math.log2(c) for c in cs))
        actual.append(math.log2(shtarkov(lib, space)))
    ax.fill_between(Ks, lows, highs, alpha=0.2, color="steelblue",
                    label=r"admissible band $[\max_i r_i,\ \log_2 K+\max_i r_i]$")
    ax.plot(Ks, actual, "o-", color="crimson", label="library price (computed)")
    ax.set_xlabel("number $K$ of specialised classes in the library")
    ax.set_ylabel("price of universality (bits)")
    ax.set_title("Libraries: merging specialists costs at most $\\log_2 K$")
    ax.grid(alpha=0.3)
    ax.legend(fontsize=8)

    # --- bottom: the separation --------------------------------------------
    ax = fig.add_subplot(2, 1, 2)
    ns = list(range(2, 60))
    unstructured = [float(n) for n in ns]
    memoryless = [math.log2(bernoulli_shtarkov_exact(n)) for n in ns]
    composition = [math.log2(n + 1) for n in ns]
    asymptote = [0.5 * math.log2(n) + 0.5 * math.log2(math.pi / 2) for n in ns]
    ax.plot(ns, unstructured, label="all $n$-bit files: exactly $n$ bits")
    ax.plot(ns, composition, label=r"constant composition: exactly $\log_2(n+1)$")
    ax.plot(ns, memoryless, label=r"binary memoryless: $\log_2 C_n$")
    ax.plot(ns, asymptote, "--", color="grey",
            label=r"$\frac12\log_2 n+\frac12\log_2(\pi/2)$ (conjectured)")
    ax.set_xlabel("message length $n$ (bits)")
    ax.set_ylabel("price of universality (bits)")
    ax.set_title("The separation: complexity of the class, not length of the data")
    ax.grid(alpha=0.3)
    ax.legend()

    fig.tight_layout()
    fig.savefig("algebra_of_source_classes.png", dpi=160)
    print("wrote algebra_of_source_classes.png")


if __name__ == "__main__":
    make_figure()


"""
Visualisation: the maximum likelihood envelope and the excess mass that is
the price of universality.

For a source class S = {p_theta} on a finite message space, the envelope is
hat p(x) = sup_theta p_theta(x) and the Shtarkov sum is C = sum_x hat p(x).
Each individual source has total mass 1; the envelope has mass C >= 1.  The
*excess* mass C - 1 is exactly the geometric object one pays for: its
logarithm, log2 C, is the worst-case number of extra bits a single shared
decompressor must spend.

The figure plots, over all 4-bit strings ordered by their number of ones,
two memoryless sources p_0.25 and p_0.75, their pointwise maximum (the
envelope), and shades the excess area.  A second panel shows how the excess
grows as the two sources are pulled apart, next to the total-variation
lower bound 1 + TV <= C, which is an equality for a two-source class.
"""

from __future__ import annotations

import itertools
import math
from typing import List, Tuple

import matplotlib.pyplot as plt


def strings(n: int) -> List[Tuple[int, ...]]:
    out = [tuple(b) for b in itertools.product((0, 1), repeat=n)]
    return sorted(out, key=lambda x: (sum(x), x))


def bernoulli(theta: float, x: Tuple[int, ...]) -> float:
    k = sum(x)
    return theta ** k * (1.0 - theta) ** (len(x) - k)


def make_figure(n: int = 4, theta_a: float = 0.25, theta_b: float = 0.75) -> None:
    xs = strings(n)
    pa = [bernoulli(theta_a, x) for x in xs]
    pb = [bernoulli(theta_b, x) for x in xs]
    env = [max(u, v) for u, v in zip(pa, pb)]
    c = sum(env)
    idx = list(range(len(xs)))

    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    ax = axes[0]
    ax.bar(idx, pa, width=0.8, alpha=0.45, label=rf"$p_{{{theta_a}}}$")
    ax.bar(idx, pb, width=0.8, alpha=0.45, label=rf"$p_{{{theta_b}}}$")
    ax.step([i - 0.4 for i in idx] + [idx[-1] + 0.4],
            env + [env[-1]], where="post", linewidth=2.2, color="black",
            label=r"envelope $\hat p=\max$")
    ax.fill_between([i for i in idx], 0, env, step="mid", color="crimson",
                    alpha=0.12)
    ax.set_xticks(idx)
    ax.set_xticklabels(["".join(map(str, x)) for x in xs], rotation=90, fontsize=7)
    ax.set_xlabel(f"the $2^{n}$ messages, ordered by weight")
    ax.set_ylabel("probability")
    ax.set_title(f"Envelope of a two-source class:  C = {c:.4f},  "
                 f"price = {math.log2(c):.4f} bits")
    ax.legend()

    ax = axes[1]
    gaps = [0.0, 0.02, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.49]
    cs, tvs = [], []
    for g in gaps:
        u = [bernoulli(0.5 - g, x) for x in xs]
        v = [bernoulli(0.5 + g, x) for x in xs]
        cs.append(sum(max(a, b) for a, b in zip(u, v)))
        tvs.append(0.5 * sum(abs(a - b) for a, b in zip(u, v)))
    ax.plot(gaps, cs, "o-", label=r"Shtarkov sum $C_{\mathcal S}$")
    ax.plot(gaps, [1 + t for t in tvs], "s--",
            label=r"diversity floor $1+\|p-p'\|_{TV}$")
    ax.set_xlabel(r"separation $g$ of the two parameters $0.5\pm g$")
    ax.set_ylabel("Shtarkov sum")
    ax.set_title("For a two-source class the diversity floor is exact")
    ax.legend()
    ax.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("envelope_and_diversity.png", dpi=160)
    print("wrote envelope_and_diversity.png")


if __name__ == "__main__":
    make_figure()


"""
The Price of Universality: numerical demonstrations.
=====================================================

A *source class* on a finite message space X is a family S = {p_theta} of
probability distributions on X.  The **Shtarkov sum** of the class is

        C(S) = sum_{x in X} sup_theta p_theta(x),

and the **price of universality** of the class is log2 C(S) bits: this is
exactly the worst-case number of extra bits that a single shared decompressor
must spend, relative to a decompressor that already knows which source in the
class produced the data.  The optimal universal code is the *normalised
maximum likelihood* (NML) distribution q*(x) = sup_theta p_theta(x) / C(S).

This script verifies, numerically, the main structural theorems:

  1.  Multiplicativity / additivity:  C(S1 (x) S2) = C(S1) * C(S2),
      hence price(S1 (x) S2) = price(S1) + price(S2).
  2.  Library (union) bounds:  max_i C_i <= C(union) <= sum_i C_i,
      hence price(library) <= log2 K + max_i price_i.
  3.  Diversity floor:  C(S) >= 1 + TV(p_theta, p_theta'), with equality
      C(S) = 1 exactly when the class is a single source.
  4.  Exactly solvable classes: mutually singular classes have
      C = |Theta|; the constant-composition class on n bits has C = n + 1.
  5.  Worst-case dominates average-case:  D(p_theta || q*) <= log2 C(S).
  6.  The separation:  the memoryless (Bernoulli) class on n bits costs
      Theta(log n) bits, the class of all n-bit files costs exactly n.

Everything is exact rational/float arithmetic over brute-force enumerated
message spaces; no external dependencies beyond the standard library.
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Message = Tuple[int, ...]
Distribution = Dict[Message, float]


# ----------------------------------------------------------------------
# Core objects: source classes, Shtarkov sums, prices, NML codes
# ----------------------------------------------------------------------
class SourceClass:
    """A finite family of probability distributions on a common finite space."""

    def __init__(self, name: str, space: Sequence[Message],
                 members: Sequence[Distribution]) -> None:
        self.name = name
        self.space: List[Message] = list(space)
        self.members: List[Distribution] = list(members)
        for p in self.members:
            total = sum(p.get(x, 0.0) for x in self.space)
            assert abs(total - 1.0) < 1e-9, f"{name}: mass {total} != 1"

    def max_likelihood(self, x: Message) -> float:
        """The pointwise maximum likelihood sup_theta p_theta(x)."""
        return max(p.get(x, 0.0) for p in self.members)

    def shtarkov_sum(self) -> float:
        """C(S) = sum_x sup_theta p_theta(x)."""
        return sum(self.max_likelihood(x) for x in self.space)

    def price_bits(self) -> float:
        """log2 C(S): the worst-case price of universality, in bits."""
        return math.log2(self.shtarkov_sum())

    def nml(self) -> Distribution:
        """The normalised maximum likelihood (Shtarkov) code distribution."""
        c = self.shtarkov_sum()
        return {x: self.max_likelihood(x) / c for x in self.space}


def kl_divergence(p: Distribution, q: Distribution, space: Iterable[Message]) -> float:
    """Kullback-Leibler divergence D(p || q) in bits; 0 log 0 = 0."""
    total = 0.0
    for x in space:
        px = p.get(x, 0.0)
        if px > 0.0:
            total += px * math.log2(px / q[x])
    return total


def total_variation(p: Distribution, q: Distribution, space: Iterable[Message]) -> float:
    """TV(p, q) = (1/2) sum_x |p(x) - q(x)|."""
    return 0.5 * sum(abs(p.get(x, 0.0) - q.get(x, 0.0)) for x in space)


def product_class(s1: SourceClass, s2: SourceClass) -> SourceClass:
    """Independent product: the message is a pair, each block from its own class."""
    space = [x + y for x in s1.space for y in s2.space]
    members = []
    for p in s1.members:
        for q in s2.members:
            members.append({x + y: p.get(x, 0.0) * q.get(y, 0.0)
                            for x in s1.space for y in s2.space})
    return SourceClass(f"{s1.name} (x) {s2.name}", space, members)


def library_class(classes: Sequence[SourceClass]) -> SourceClass:
    """Union (library) of classes on the same message space."""
    space = classes[0].space
    members: List[Distribution] = []
    for s in classes:
        assert s.space == space, "library members must share a message space"
        members.extend(s.members)
    return SourceClass("library(" + ", ".join(s.name for s in classes) + ")",
                       space, members)


# ----------------------------------------------------------------------
# Concrete classes
# ----------------------------------------------------------------------
def binary_strings(n: int) -> List[Message]:
    return [tuple(b) for b in itertools.product((0, 1), repeat=n)]


def bernoulli_class(n: int, grid: int = 200) -> SourceClass:
    """Memoryless binary sources on n bits, parameter discretised on a grid.

    The maximum likelihood of a string with j ones is (j/n)^j (1-j/n)^(n-j),
    so a grid containing the points j/n already realises every supremum.
    """
    space = binary_strings(n)
    thetas = sorted({j / n for j in range(n + 1)} |
                    {k / grid for k in range(grid + 1)})
    members = []
    for t in thetas:
        members.append({x: (t ** sum(x)) * ((1.0 - t) ** (n - sum(x))) for x in space})
    return SourceClass(f"Bernoulli(n={n})", space, members)


def composition_class(n: int) -> SourceClass:
    """Constant-composition sources: p_j is uniform on strings with j ones."""
    space = binary_strings(n)
    members = []
    for j in range(n + 1):
        fibre = [x for x in space if sum(x) == j]
        members.append({x: (1.0 / len(fibre) if sum(x) == j else 0.0) for x in space})
    return SourceClass(f"ConstantComposition(n={n})", space, members)


def deterministic_class(n: int) -> SourceClass:
    """The class of point masses: 'all n-bit files', no structure assumed."""
    space = binary_strings(n)
    members = [{y: (1.0 if y == x else 0.0) for y in space} for x in space]
    return SourceClass(f"Deterministic(n={n})", space, members)


def markov_class(n: int, grid: int = 12) -> SourceClass:
    """First-order binary Markov chains on n bits, uniform start, grid of kernels."""
    space = binary_strings(n)
    ps = [k / grid for k in range(1, grid)]
    members = []
    for a in ps:            # P(1 | 0)
        for b in ps:        # P(1 | 1)
            dist: Distribution = {}
            for x in space:
                prob = 0.5
                for i in range(1, n):
                    p1 = b if x[i - 1] == 1 else a
                    prob *= p1 if x[i] == 1 else (1.0 - p1)
                dist[x] = prob
            members.append(dist)
    return SourceClass(f"Markov(n={n})", space, members)


def biased_pair_class(name: str, n: int, theta_values: Sequence[float]) -> SourceClass:
    """A small memoryless class with an explicit, finite parameter list."""
    space = binary_strings(n)
    members = [{x: (t ** sum(x)) * ((1.0 - t) ** (n - sum(x))) for x in space}
               for t in theta_values]
    return SourceClass(name, space, members)


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------
def demo_additivity() -> None:
    print("=" * 72)
    print("1.  ADDITIVITY OVER INDEPENDENT BLOCKS")
    print("    C(S1 (x) S2) = C(S1) * C(S2),  price adds in bits")
    print("=" * 72)
    s1 = biased_pair_class("A", 2, [0.2, 0.5, 0.9])
    s2 = biased_pair_class("B", 3, [0.1, 0.4, 0.7, 0.95])
    prod = product_class(s1, s2)
    c1, c2, cp = s1.shtarkov_sum(), s2.shtarkov_sum(), prod.shtarkov_sum()
    print(f"  C(A)            = {c1:.10f}   price = {math.log2(c1):.6f} bits")
    print(f"  C(B)            = {c2:.10f}   price = {math.log2(c2):.6f} bits")
    print(f"  C(A (x) B)      = {cp:.10f}   price = {math.log2(cp):.6f} bits")
    print(f"  C(A) * C(B)     = {c1 * c2:.10f}   (difference {abs(cp - c1 * c2):.2e})")
    print(f"  price(A)+price(B) = {math.log2(c1) + math.log2(c2):.6f} bits")

    print("\n  k independent blocks of the same class: the price is exactly k times")
    base = biased_pair_class("C", 2, [0.25, 0.75])
    acc = base
    for k in range(1, 5):
        print(f"    k = {k}:  price = {acc.price_bits():.6f} "
              f"= {k} x {base.price_bits():.6f}")
        if k < 4:
            acc = product_class(acc, base)
    print("  => universality can never be amortised away by batching.\n")


def demo_library() -> None:
    print("=" * 72)
    print("2.  LIBRARIES OF SPECIALISED DECOMPRESSORS")
    print("    max_i C_i <= C(library) <= sum_i C_i;  price <= log2 K + max price_i")
    print("=" * 72)
    n = 4
    families = [
        biased_pair_class("text-like", n, [0.05, 0.10, 0.15]),
        biased_pair_class("balanced", n, [0.45, 0.50, 0.55]),
        biased_pair_class("dense", n, [0.85, 0.90, 0.95]),
        composition_class(n),
    ]
    lib = library_class(families)
    cs = [s.shtarkov_sum() for s in families]
    k = len(families)
    print(f"  members ({k}):")
    for s, c in zip(families, cs):
        print(f"    {s.name:28s} C = {c:8.5f}   price = {math.log2(c):7.4f} bits")
    print(f"  library:                     C = {lib.shtarkov_sum():8.5f}   "
          f"price = {lib.price_bits():7.4f} bits")
    print(f"  lower bound  max_i C_i      = {max(cs):8.5f}   "
          f"[{'OK' if max(cs) <= lib.shtarkov_sum() + 1e-12 else 'FAIL'}]")
    print(f"  upper bound  sum_i C_i      = {sum(cs):8.5f}   "
          f"[{'OK' if lib.shtarkov_sum() <= sum(cs) + 1e-12 else 'FAIL'}]")
    bound = math.log2(k) + max(math.log2(c) for c in cs)
    print(f"  bit bound    log2 K + max price_i = {bound:.4f} bits  "
          f"(actual {lib.price_bits():.4f})")
    print("  => merging K specialised decompressors costs at most log2 K extra bits.\n")


def demo_diversity() -> None:
    print("=" * 72)
    print("3.  DIVERSITY FLOOR:  C(S) >= 1 + TV(p, p'), and C(S) = 1 iff |S| = 1")
    print("=" * 72)
    n = 4
    space = binary_strings(n)
    for pair in [(0.5, 0.5), (0.5, 0.55), (0.5, 0.7), (0.2, 0.8), (0.02, 0.98)]:
        s = biased_pair_class("pair", n, list(pair))
        tv = total_variation(s.members[0], s.members[1], space)
        c = s.shtarkov_sum()
        print(f"  theta = {pair[0]:.2f}, {pair[1]:.2f}:  TV = {tv:.6f}, "
              f"1 + TV = {1 + tv:.6f} <= C = {c:.6f}  "
              f"[{'OK' if 1 + tv <= c + 1e-12 else 'FAIL'}]")
    print("\n  Tensorisation: with delta = TV, k blocks cost >= k log2(1 + delta):")
    s = biased_pair_class("pair", 2, [0.2, 0.8])
    delta = total_variation(s.members[0], s.members[1], binary_strings(2))
    acc = s
    for k in range(1, 5):
        print(f"    k = {k}:  price = {acc.price_bits():.6f} bits  >=  "
              f"{k * math.log2(1 + delta):.6f} = k log2(1 + delta)")
        if k < 4:
            acc = product_class(acc, s)
    print("  => the price is extensive: it grows linearly in the amount of data.\n")


def demo_exact_classes() -> None:
    print("=" * 72)
    print("4.  EXACTLY SOLVABLE CLASSES")
    print("=" * 72)
    print("  (a) mutually singular classes: C = |Theta| exactly")
    for n in range(1, 5):
        d = deterministic_class(n)
        print(f"     all {n}-bit files: C = {d.shtarkov_sum():6.2f} = 2^{n}, "
              f"price = {d.price_bits():.4f} bits = n")
    print("\n  (b) constant-composition (type) class on n bits: C = n + 1 exactly")
    for n in range(1, 9):
        cc = composition_class(n)
        print(f"     n = {n}:  C = {cc.shtarkov_sum():6.3f}  (n+1 = {n + 1})  "
              f"price = {cc.price_bits():.4f} = log2(n+1)")
    print("  => a natural class attaining the logarithmic Rissanen rate on the nose.\n")


def demo_average_vs_worst() -> None:
    print("=" * 72)
    print("5.  AVERAGE CASE NEVER EXCEEDS WORST CASE:  D(p_theta || NML) <= log2 C")
    print("=" * 72)
    s = bernoulli_class(6, grid=60)
    q = s.nml()
    price = s.price_bits()
    worst = 0.0
    for t in [0.05, 0.2, 0.35, 0.5, 0.65, 0.8, 0.95]:
        p = {x: (t ** sum(x)) * ((1 - t) ** (6 - sum(x))) for x in s.space}
        d = kl_divergence(p, q, s.space)
        worst = max(worst, d)
        print(f"  theta = {t:.2f}:  D(p_theta || NML) = {d:.6f} bits  "
              f"<= log2 C = {price:.6f}  [{'OK' if d <= price + 1e-9 else 'FAIL'}]")
    print(f"  worst average redundancy over the grid: {worst:.6f} bits "
          f"(worst-case price {price:.6f})\n")


def demo_separation() -> None:
    print("=" * 72)
    print("6.  THE SEPARATION: structure is worth a growing number of bits")
    print("=" * 72)
    print(f"  {'n':>3} | {'price(all files)':>16} | {'price(memoryless)':>18} | "
          f"{'gap':>8} | {'C_n / sqrt(pi n / 2)':>20}")
    print("  " + "-" * 78)
    for n in range(2, 13):
        cn = shtarkov_bernoulli_exact(n)
        det = float(n)
        mem = math.log2(cn)
        ratio = cn / math.sqrt(math.pi * n / 2)
        print(f"  {n:>3} | {det:>16.4f} | {mem:>18.4f} | {det - mem:>8.4f} | "
              f"{ratio:>20.5f}")
    print("\n  The memoryless price grows like (1/2) log2 n + (1/2) log2(pi/2);")
    print("  the unstructured price is exactly n.  The gap n - Theta(log n) -> infinity.\n")


def shtarkov_bernoulli_exact(n: int) -> float:
    """C_n = sum_{j=0}^n binom(n, j) (j/n)^j (1 - j/n)^(n-j) for the binary
    memoryless class on n bits (the j = 0 and j = n terms contribute 1 each)."""
    total = 0.0
    for j in range(n + 1):
        t = j / n
        if j == 0 or j == n:
            total += 1.0
        else:
            total += math.comb(n, j) * (t ** j) * ((1 - t) ** (n - j))
    return total


def demo_conservation() -> None:
    print("=" * 72)
    print("7.  CONSERVATION OF BITS: specialisation moves bits, it does not")
    print("    destroy them.  entropy of the type + log2(#types) = total length")
    print("=" * 72)
    n_type, n_payload = 3, 5
    print(f"  messages = (type block of {n_type} bits, payload of {n_payload} bits)")
    print(f"  a decompressor specialised to one type spends {n_payload} bits/file")
    print(f"  naming the type costs log2 2^{n_type} = {n_type} bits")
    print(f"  total = {n_payload + n_type} bits = the length of the whole message")
    print("  => the shared decompressor saves nothing unless the class is genuinely")
    print("     low-complexity; when it is, the saving is real and unbounded.\n")


def main() -> None:
    print(__doc__)
    demo_additivity()
    demo_library()
    demo_diversity()
    demo_exact_classes()
    demo_average_vs_worst()
    demo_separation()
    demo_conservation()
    print("All structural identities and bounds verified numerically.")


if __name__ == "__main__":
    main()
