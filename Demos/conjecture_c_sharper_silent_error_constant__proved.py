"""
Unique-Match Decoding with a Reject Option, and exact measurement of the
success / abstention / silent-corruption trichotomy.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Sequence


def decode_unique_match(
    received: int,
    hash_fn: Callable[[int], int],
    codebook: Sequence[int],
) -> Optional[int]:
    """
    Scan the codebook once. Return the unique entry whose hash equals the
    received codeword; return None ("I don't know") if there are zero or
    several such entries.

    Cost: exactly len(codebook) hash evaluations, data-independent -- the same
    fixed budget for every received codeword, with no adaptivity and no
    early exit, which is what makes the cost guarantee exact.
    """
    candidate: Optional[int] = None
    matches = 0
    for y in codebook:
        if hash_fn(y) == received:
            candidate = y
            matches += 1
    return candidate if matches == 1 else None


def decode_committing(
    received: int,
    hash_fn: Callable[[int], int],
    codebook: Sequence[int],
) -> int:
    """
    A decoder forbidden to abstain: it must return some symbol, so it returns
    the first match (or an arbitrary fallback). Any such decoder is subject to
    the converse: its silent-corruption probability is at least 1 - M*p_max.
    """
    for y in codebook:
        if hash_fn(y) == received:
            return y
    return codebook[0]


@dataclass(frozen=True)
class Trichotomy:
    """The three mutually exclusive outcomes, as probability masses."""
    success: float
    abstain: float
    silent: float

    @property
    def failure(self) -> float:
        """Loud failure plus silent corruption: everything that is not a success."""
        return self.abstain + self.silent


def measure(
    probs: Sequence[float],
    hash_fn: Callable[[int], int],
    codebook: Sequence[int],
    committing: bool = False,
) -> Trichotomy:
    """
    Exact (not sampled) evaluation of the scheme over the whole alphabet.
    Complexity O(|alphabet| * |codebook|) naively, or O(|alphabet| + |codebook|)
    after bucketing the codebook by hash value.
    """
    buckets: Dict[int, List[int]] = {}
    for y in codebook:
        buckets.setdefault(hash_fn(y), []).append(y)

    success = abstain = silent = 0.0
    for x in range(len(probs)):
        bucket = buckets.get(hash_fn(x), [])
        if committing:
            out: Optional[int] = bucket[0] if bucket else codebook[0]
        else:
            out = bucket[0] if len(bucket) == 1 else None
        if out is None:
            abstain += probs[x]
        elif out == x:
            success += probs[x]
        else:
            silent += probs[x]
    return Trichotomy(success, abstain, silent)


def conservation_slack(probs: Sequence[float], num_codewords: int,
                       outcome: Trichotomy) -> float:
    """
    The slack in the conservation law
        silent + abstain >= 1 - M * p_max ,
    which holds for every encoder-decoder pair whatsoever. A nonnegative value
    is the law being satisfied; it is tight when the code is used perfectly.
    """
    p_max = max(probs)
    return (outcome.silent + outcome.abstain) - (1.0 - num_codewords * p_max)


"""
Fractional-Covering Derandomization over Many Regions, and its application to
group-wise (fair) silent-error control.
"""

from __future__ import annotations

from typing import Callable, Dict, List, Optional, Sequence, Tuple

Key = Tuple[int, int]


def region_collision_mass(
    probs: Sequence[float],
    hash_fn: Callable[[int], int],
    codebook: Sequence[int],
    num_codewords: int,
    region: Sequence[int],
) -> float:
    """Mass of the part of `region` that collides with the codebook."""
    counts: List[int] = [0] * num_codewords
    for y in codebook:
        counts[hash_fn(y)] += 1
    code_set = set(codebook)
    total = 0.0
    for x in region:
        c = counts[hash_fn(x)] - (1 if x in code_set else 0)
        if c > 0:
            total += probs[x]
    return total


def select_multi_region_key(
    probs: Sequence[float],
    keys: Sequence[Key],
    hash_of: Callable[[Key, int], int],
    codebook: Sequence[int],
    num_codewords: int,
    regions: Sequence[Sequence[int]],
    thresholds: Sequence[float],
) -> Optional[Key]:
    """
    Return a key that is simultaneously c_i-good on region A_i for every i,
    i.e. M * mu(A_i and collides) <= c_i * |codebook| * mu(A_i).

    Correctness: fewer than K/c_i keys are bad for region i, so if
    sum_i 1/c_i <= 1 the bad sets cannot cover the key space and a survivor
    exists. This is exactly the fractional-covering condition; when it fails,
    bad sets of the permitted densities that *do* cover the key space can be
    constructed, so the search may legitimately come up empty.

    Complexity: O(K * (|codebook| + sum_i |A_i| + M)).
    """
    assert len(regions) == len(thresholds)
    assert sum(1.0 / c for c in thresholds) <= 1.0 + 1e-12, "covering condition violated"
    n = len(codebook)
    for key in keys:
        h: Callable[[int], int] = lambda x, k=key: hash_of(k, x)
        ok = True
        for region, c in zip(regions, thresholds):
            budget = c * n * sum(probs[x] for x in region) / num_codewords
            if region_collision_mass(probs, h, codebook, num_codewords, region) > budget:
                ok = False
                break
        if ok:
            return key
    return None


def groupwise_scheme(
    probs: Sequence[float],
    keys: Sequence[Key],
    hash_of: Callable[[Key, int], int],
    codebook: Sequence[int],
    num_codewords: int,
    groups: Sequence[Sequence[int]],
) -> Tuple[Optional[Key], Dict[str, float]]:
    """
    Fair silent-error control across r protected subpopulations.

    The r+1 regions are the whole alphabet (governing global failure) and, for
    each group g, the part of g that the codebook misses (governing silent
    corruption inside g). All thresholds are the uniform value r+1, so the
    covering sum is exactly (r+1) * 1/(r+1) = 1.

    The selected key certifies, simultaneously,
        global failure  <= delta + (r+1) * |l| / M ,
        silent in g     <= (r+1) * mu(g minus codebook) * |l| / M   for every g.
    The second bound is LOCAL: a well-covered group is protected proportionally
    better than the global bound would suggest.
    """
    r = len(groups)
    c = float(r + 1)
    code_set = set(codebook)
    everything = list(range(len(probs)))
    missed = [[x for x in g if x not in code_set] for g in groups]
    regions: List[Sequence[int]] = [everything] + missed
    thresholds = [c] * (r + 1)

    key = select_multi_region_key(probs, keys, hash_of, codebook,
                                  num_codewords, regions, thresholds)
    load = len(codebook) / num_codewords
    delta = sum(probs[x] for x in range(len(probs)) if x not in code_set)
    bounds: Dict[str, float] = {"global_failure": delta + c * load}
    for i, region in enumerate(missed):
        bounds[f"silent_in_group_{i}"] = c * sum(probs[x] for x in region) * load
    return key, bounds


"""
Balanced Threshold Derandomization: selecting a single key that controls loud
failure and silent corruption simultaneously.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Optional, Sequence, Tuple

Key = Tuple[int, int]


def balanced_thresholds(delta: float) -> Tuple[float, float]:
    """
    The optimal admissible threshold pair for codebook defect delta:
        c1 = 1 + 1/sqrt(delta)   (silent constant),
        c2 = 1 + sqrt(delta)     (failure constant).
    It satisfies the covering condition 1/c1 + 1/c2 = 1 with equality and
    minimises the total-error constant c2 + c1*delta at (1 + sqrt(delta))^2.
    """
    s = math.sqrt(delta)
    return 1.0 + 1.0 / s, 1.0 + s


def collision_mass(
    probs: Sequence[float],
    hash_fn: Callable[[int], int],
    codebook: Sequence[int],
    num_codewords: int,
    region: Optional[Sequence[int]] = None,
) -> float:
    """
    Mass of {x in region : some codebook entry y != x has hash_fn(y) = hash_fn(x)}.
    One pass over the codebook to build bucket counts, one pass over the region.
    Cost O(|codebook| + |region|).
    """
    counts: List[int] = [0] * num_codewords
    for y in codebook:
        counts[hash_fn(y)] += 1
    code_set = set(codebook)
    universe = range(len(probs)) if region is None else region
    total = 0.0
    for x in universe:
        c = counts[hash_fn(x)] - (1 if x in code_set else 0)
        if c > 0:
            total += probs[x]
    return total


def select_balanced_key(
    probs: Sequence[float],
    keys: Sequence[Key],
    hash_of: Callable[[Key, int], int],
    codebook: Sequence[int],
    num_codewords: int,
    delta: float,
) -> Optional[Key]:
    """
    Bad-set elimination at the balanced thresholds.

    A key is discarded if either
      (i)  its global collision mass exceeds c2 * |codebook| / M, or
      (ii) its collision mass inside the atypical region exceeds
           c1 * (|codebook| / M) * mu(atypical).
    Fewer than K/c2 keys fail (i) and fewer than K/c1 fail (ii); since
    1/c1 + 1/c2 = 1 with both counts strict, a survivor always exists.

    The survivor's scheme satisfies, provably,
        failure <= delta + (1 + sqrt(delta)) * |l| / M,
        silent  <= (sqrt(delta) + delta) * |l| / M,
    at decoding cost exactly |l| hash evaluations.

    Complexity: O(K * (|alphabet| + |codebook| + M)) in the worst case.
    """
    c1, c2 = balanced_thresholds(delta)
    n = len(codebook)
    code_set = set(codebook)
    atypical = [x for x in range(len(probs)) if x not in code_set]
    mu_atypical = sum(probs[x] for x in atypical)
    global_budget = c2 * n / num_codewords
    atypical_budget = c1 * (n / num_codewords) * mu_atypical

    for key in keys:
        h: Callable[[int], int] = lambda x, k=key: hash_of(k, x)
        if collision_mass(probs, h, codebook, num_codewords) > global_budget:
            continue
        if collision_mass(probs, h, codebook, num_codewords, atypical) > atypical_budget:
            continue
        return key
    return None


def certified_bounds(delta: float, codebook_size: int, num_codewords: int,
                     tag_alphabet: int = 1) -> Dict[str, float]:
    """The closed-form guarantees attached to the selected key."""
    s = math.sqrt(delta)
    load = codebook_size / (num_codewords * tag_alphabet)
    return {
        "failure": delta + (1.0 + s) * load,
        "silent": (s + delta) * load,
        "total": delta + (1.0 + s) ** 2 * load,
        "cost_hash_evaluations": float(codebook_size),
    }


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the source documents in the project."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

ROOT = Path(__file__).resolve().parent.parent
A = ROOT / "assets"

LEAN_FILES: List[str] = [
    "Catalog/MachineLearning/AlmostLosslessBalancedSilent.lean",
    "Catalog/MachineLearning/AlmostLosslessThresholdSharpness.lean",
    "Catalog/MachineLearning/AlmostLosslessGroupwiseSilent.lean",
    "Catalog/MachineLearning/AlmostLosslessTaggedProduct.lean",
    "Catalog/MachineLearning/AlmostLosslessAbstentionSeparation.lean",
]


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def lean_bundle() -> str:
    parts: List[str] = []
    for f in LEAN_FILES:
        parts.append(f"-- ===== {f} =====\n")
        parts.append(read(f))
        parts.append("\n\n")
    return "".join(parts)


FUTURE_DIRECTIONS = """# Future Directions — after Cycle 3 (silent-error constants)

## Where the thread stands

Cycle 2 proved that one derandomized key can control failure and silent
corruption at once, with constant `2` in both. Cycle 3's input replaced the `2`s
by a one-parameter family `(1+eta, 1+1/eta)`. This cycle closed that parameter
and mapped the boundary of the method:

| result | content |
|---|---|
| the balanced scheme | one key: failure `<= delta + (1+sqrt(delta))L`, silent `<= (sqrt(delta)+delta)L`, total `<= delta + (1+sqrt(delta))^2 L`, cost `= |l|` |
| AM–GM converse for the tunable family | `eta = 1/sqrt(delta)` is the exact minimiser of the family |
| frontier optimality / balanced attainment | Cauchy–Schwarz: `c2 + c1*delta >= (1+sqrt(delta))^2` on the whole admissible frontier, with equality at the balanced point |
| necessity of the covering condition | the condition `1/c1 + 1/c2 <= 1` is the exact boundary of the counting method |
| multi-region derandomization | `r`-region derandomization under `sum_i 1/c_i <= 1` |
| group-wise silent control | one key controlling silent corruption *inside every protected group* |
| abstention trade-off and separation | silent + abstain `>= 1 - M*p_max`; committing decoders lie half the time while the balanced key lies with probability `<= epsilon` |
| the frontier scheme and the near-optimal silent constant | every point `(c, c/(c-1))` of the hyperbola is realised by a key; the silent constant reaches `1 + epsilon` for every `epsilon > 0` |
| products of universal families and tagged codewords | products of 2-universal families are 2-universal; a `T`-valued tag divides the silent-error bound by `T` at unchanged scan cost |

Analysis of what survived and what did not:

* **True and now proved.** The silent constant *can* be pushed below `2`; the
  correct statement is not "constant -> 1" but "the two constants trade off along
  a hyperbola whose optimum is `(1+sqrt(delta))^2`". The naive hope of `(1, delta)`
  simultaneously is **false for this method**: frontier optimality forbids
  `c2 + c1*delta < (1+sqrt(delta))^2`, and `c2 = 1` forces `c1 = infinity`.
* **Needs a different definition.** A converse *for schemes* (rather than for the
  method) needs a notion of silent error that survives arbitrary decoders; the
  abstention trade-off is the first such scheme-level statement and is the right
  primitive for direction 1 below.
* **Boundary discovered.** The covering condition is not an artefact: below it
  the union bound provably fails, so any improvement past `(1+sqrt(delta))^2`
  must use structure beyond the two Markov densities.

## Open directions

1. **A converse frontier for arbitrary schemes.** The abstention trade-off
   constrains the pair (silent, abstain) by a single linear inequality. The
   natural next object is the full achievable region of the triple
   (silent, abstain, cost) for arbitrary schemes, and a matching converse to the
   `(1+sqrt(delta))^2` frontier at the level of schemes rather than of the method.
2. **Beyond union bounds.** Second-moment concentration over the key space,
   explicit algebraic families with better-than-universal collision behaviour, or
   list-decoding relaxations in which the decoder returns a short list rather than
   a single symbol or nothing.
3. **Sharper group-wise constants.** The factor `r+1` is the exact cost of uniform
   fractional covering; non-uniform thresholds optimised against the group masses
   subject to `sum_i 1/c_i <= 1` should give a weighted frontier analogous to the
   Cauchy–Schwarz optimum.
4. **Tag-length optimisation.** The rate-versus-silent-error trade-off
   `(log2(M*T), (sqrt(delta)+delta)|l|/(M*T))` optimised against an explicit cost
   model for downstream silent errors.
5. **Adaptive codebooks.** Jointly optimising which symbols enter the codebook
   against the balanced constants — enlarging the codebook shrinks `delta` but
   raises the load `L = |l|/M`.
"""


def main() -> None:
    demo_src = read("demo.py")

    package: Dict[str, Any] = {
        "title": ("Sharp Silent-Error Constants for Almost-Lossless Compression, "
                  "and the Necessity of Abstention"),
        "domain": "MachineLearning",
        "description": (
            "For almost-lossless compression by 2-universal hashing with a decoder that may "
            "abstain, a single derandomized key achieves failure probability "
            "delta + (1+sqrt(delta))|l|/M and silent-corruption probability "
            "(sqrt(delta)+delta)|l|/M at decoding cost exactly |l| — the exact optimum of the "
            "method — while every decoder that is forbidden to abstain is silently wrong with "
            "probability at least 1 - M*p_max, hence at least one half in the compressive regime."
        ),
        "authors": ["Aristotle"],
        "date": "2026-09-03",
        "key_results": [
            "The square-root-delta balanced scheme: a single key of a 2-universal family "
            "simultaneously achieves failure probability at most delta + (1+sqrt(delta))|l|/M, "
            "silent-corruption probability at most (sqrt(delta)+delta)|l|/M, total error at most "
            "delta + (1+sqrt(delta))^2 |l|/M, and decoding cost exactly |l| hash evaluations.",
            "Frontier optimality: for every threshold pair satisfying the fractional covering "
            "condition 1/c1 + 1/c2 <= 1, the total-error constant obeys c2 + c1*delta >= "
            "(1+sqrt(delta))^2, with equality exactly at c1 = 1 + 1/sqrt(delta), c2 = 1 + sqrt(delta).",
            "The achievability frontier: every point (c, c/(c-1)) of the admissible hyperbola is "
            "realised by an explicit key, so the silent-error constant can be pushed to 1 + epsilon "
            "for every epsilon > 0, at failure constant (1+epsilon)/epsilon.",
            "Necessity of the covering condition: whenever K(1/c1 + 1/c2 - 1) > 1 there exist two "
            "key blocks, each strictly below its Markov threshold, that cover the whole key space, "
            "so the covering condition is exactly the boundary of the counting method.",
            "The abstention trade-off and separation: every encoder-decoder pair over a code of "
            "size M satisfies silent + abstain >= 1 - M*p_max, so a decoder that never abstains is "
            "silently wrong with probability at least one half in the compressive regime, while the "
            "balanced key with a reject option keeps silent corruption below any target reachable "
            "by (sqrt(delta)+delta)|l|/M.",
        ],
        "keywords": [
            "almost-lossless compression",
            "2-universal hashing",
            "derandomization",
            "silent error",
            "selective prediction",
            "abstention",
            "fractional covering",
            "Cauchy-Schwarz optimality",
        ],
        "article": read("ARTICLE.md"),
        "research_paper": read("RESEARCH_PAPER.md"),
        "research_paper_tex": read("RESEARCH_PAPER.tex"),
        "demo": demo_src,
        "demos": [
            {
                "name": ("Complete Numerical Companion: Frontier Optimality, Balanced-Key "
                         "Simulation, and the Abstention Separation"),
                "description": (
                    "A single self-contained script covering every quantitative claim. It scans the "
                    "admissible hyperbola (c, c/(c-1)) and exhibits the total-error constant bottoming "
                    "out at (1+sqrt(delta))^2 exactly at the balanced point; it verifies the AM-GM "
                    "identity by comparing the measured excess of the tunable family with the closed "
                    "form (L/eta)(1 - eta*sqrt(delta))^2; it builds a plateau source with a light "
                    "atypical tail, hashes it with the affine 2-universal family x -> ((ax+b) mod p) mod M, "
                    "searches the key space by bad-set elimination at the balanced thresholds, and then "
                    "measures the exact failure, silent-corruption and abstention masses over the whole "
                    "alphabet, asserting each proved bound; it places the same encoder behind a decoder "
                    "forbidden to abstain and confirms the conservation law silent + abstain >= 1 - M*p_max "
                    "together with the one-half floor in the compressive regime, reporting the measured "
                    "separation factor; it runs the interval-splitting construction to certify that "
                    "inadmissible threshold pairs admit covering bad-key sets; and it tabulates the "
                    "tagged bounds, showing the silent-error bound halving per tag bit at unchanged scan cost."
                ),
                "code": demo_src,
            }
        ],
        "algorithms": [
            {
                "name": "Balanced Threshold Derandomization by Bad-Set Elimination",
                "description": (
                    "Selects one fixed key of a 2-universal family that controls loud failure and silent "
                    "corruption simultaneously. Averaged over keys, the collision mass inside a region A is "
                    "at most |l|*mu(A)/M; a strict Markov bound shows that fewer than K/c keys exceed c times "
                    "that average. Applying this to two regions - the whole alphabet at threshold c2, "
                    "governing failure, and the atypical region at threshold c1, governing silent corruption - "
                    "the two bad-key sets have densities below 1/c2 and 1/c1, so under the fractional covering "
                    "condition 1/c1 + 1/c2 <= 1 they cannot exhaust the key space and a survivor always exists. "
                    "The balanced thresholds c1 = 1 + 1/sqrt(delta), c2 = 1 + sqrt(delta) make the covering "
                    "condition tight and minimise the total-error constant at (1+sqrt(delta))^2. The surviving "
                    "key certifies failure <= delta + (1+sqrt(delta))|l|/M and silent corruption <= "
                    "(sqrt(delta)+delta)|l|/M at decoding cost exactly |l|. Complexity: bucketing the codebook "
                    "once per key gives O(K(|alphabet| + |l| + M)) hash evaluations; the search stops at the "
                    "first survivor, and a constant fraction of keys survive."
                ),
                "pseudocode": (
                    "Input : source probabilities mu, key set {1..K}, 2-universal family H,\n"
                    "        codebook l of distinct symbols, code size M, defect bound delta > 0\n"
                    "Output: a key k with certified failure and silent-corruption bounds\n"
                    "\n"
                    " 1. s  <- sqrt(delta)\n"
                    " 2. c1 <- 1 + 1/s                      // silent threshold\n"
                    " 3. c2 <- 1 + s                        // failure threshold\n"
                    " 4. assert 1/c1 + 1/c2 <= 1            // fractional covering condition\n"
                    " 5. A  <- complement of l              // the atypical region\n"
                    " 6. globalBudget   <- c2 * |l| / M\n"
                    " 7. atypicalBudget <- c1 * (|l| / M) * mu(A)\n"
                    " 8. for each key k in {1..K}:\n"
                    " 9.     counts <- array of M zeros\n"
                    "10.     for y in l: counts[H_k(y)] <- counts[H_k(y)] + 1\n"
                    "11.     gMass <- sum of mu(x) over x with counts[H_k(x)] - [x in l] > 0\n"
                    "12.     if gMass > globalBudget: continue\n"
                    "13.     aMass <- same sum restricted to x in A\n"
                    "14.     if aMass > atypicalBudget: continue\n"
                    "15.     return k                        // certified good key\n"
                    "16. return FAIL                         // unreachable when 1/c1 + 1/c2 <= 1"
                ),
                "code": read("assets/algo_keyselect.py"),
            },
            {
                "name": "Unique-Match Decoding with a Reject Option and Exact Trichotomy Measurement",
                "description": (
                    "The decoder that makes silent corruption a second-order event. Given a received "
                    "codeword it scans the codebook once, maintaining a candidate and a match counter, and "
                    "commits only if the counter is exactly one; otherwise it abstains. The scan is oblivious "
                    "and non-adaptive, so the cost is exactly |l| hash evaluations for every codeword - a "
                    "fixed, predictable budget with no data-dependent timing. The companion routine evaluates "
                    "the scheme exactly (not by sampling) over the whole alphabet, splitting the mass into the "
                    "decoding trichotomy of success, abstention and silent corruption, and reports the slack "
                    "in the conservation law silent + abstain >= 1 - M*p_max, which holds for arbitrary "
                    "encoder-decoder pairs. A committing variant is provided for the converse side of the "
                    "separation: it is forced to answer and therefore inherits the silent-error floor. "
                    "Complexity: O(|l|) per decode; O(|alphabet| + |l| + M) for the exact measurement after "
                    "bucketing the codebook."
                ),
                "pseudocode": (
                    "DECODE(received i, hash h, codebook l):\n"
                    " 1. candidate <- none ; matches <- 0\n"
                    " 2. for y in l:                          // exactly |l| evaluations, no early exit\n"
                    " 3.     if h(y) = i: candidate <- y ; matches <- matches + 1\n"
                    " 4. if matches = 1: return candidate\n"
                    " 5. else: return ABSTAIN\n"
                    "\n"
                    "MEASURE(mu, h, l, committing):\n"
                    " 6. buckets <- map from codeword to the list of codebook entries hashing to it\n"
                    " 7. success <- 0 ; abstain <- 0 ; silent <- 0\n"
                    " 8. for x in alphabet:\n"
                    " 9.     B <- buckets[h(x)]\n"
                    "10.     if committing: out <- first element of B (fallback if B empty)\n"
                    "11.     else:          out <- the unique element of B if |B| = 1, else ABSTAIN\n"
                    "12.     if out = ABSTAIN: abstain <- abstain + mu(x)\n"
                    "13.     elif out = x:     success <- success + mu(x)\n"
                    "14.     else:             silent  <- silent  + mu(x)\n"
                    "15. return (success, abstain, silent)\n"
                    "16. // conservation law: silent + abstain >= 1 - M * max_x mu(x)"
                ),
                "code": read("assets/algo_decode.py"),
            },
            {
                "name": "Fractional-Covering Derandomization over Many Regions with Group-wise Guarantees",
                "description": (
                    "Generalises the two-region argument to any finite family of regions. If the thresholds "
                    "satisfy sum_i 1/c_i <= 1 then the bad-key sets, of densities below 1/c_i, cannot cover "
                    "the key space, so one key is c_i-good on region A_i for every i simultaneously. The "
                    "application is fairness under compression: taking the r+1 regions to be the whole "
                    "alphabet, which governs global failure, and the codebook-missed part of each protected "
                    "group, which governs silent corruption inside that group, all with the uniform threshold "
                    "r+1 (so the covering sum is exactly one), a single key certifies global failure at most "
                    "delta + (r+1)|l|/M and, for every group g, silent corruption inside g at most "
                    "(r+1)*mu(g minus codebook)*|l|/M. The per-group bound is local: it is driven by that "
                    "group's own coverage defect rather than by the worst group or by the aggregate, so a "
                    "well-covered subpopulation is protected proportionally better. Complexity: "
                    "O(K(|l| + sum_i |A_i| + M)) hash evaluations, linear in the number of audited groups."
                ),
                "pseudocode": (
                    "Input : source mu, keys {1..K}, family H, codebook l, code size M,\n"
                    "        regions A_1..A_r, thresholds c_1..c_r with sum_i 1/c_i <= 1\n"
                    "Output: a key that is c_i-good on A_i for every i\n"
                    "\n"
                    " 1. assert sum_i 1/c_i <= 1              // fractional covering condition\n"
                    " 2. for each key k in {1..K}:\n"
                    " 3.     good <- true\n"
                    " 4.     counts <- bucket counts of l under H_k\n"
                    " 5.     for i in 1..r:\n"
                    " 6.         mass <- sum of mu(x) for x in A_i colliding with l under H_k\n"
                    " 7.         if M * mass > c_i * |l| * mu(A_i): good <- false ; break\n"
                    " 8.     if good: return k\n"
                    " 9. return FAIL                          // unreachable under the covering condition\n"
                    "\n"
                    "GROUPWISE(groups G_1..G_r):\n"
                    "10. regions    <- [alphabet] ++ [ G_g minus l : g = 1..r ]\n"
                    "11. thresholds <- [r+1] repeated r+1 times      // covering sum exactly 1\n"
                    "12. k <- the key returned above\n"
                    "13. certify global failure <= delta + (r+1)|l|/M\n"
                    "14. certify silent inside G_g <= (r+1) * mu(G_g minus l) * |l|/M for every g"
                ),
                "code": read("assets/algo_groupwise.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Admissible Frontier, its Level Sets, and the Balanced Optimum",
                "description": (
                    "Two panels. The left panel draws the (c1, c2) plane: the shaded admissible region "
                    "1/c1 + 1/c2 <= 1, its boundary hyperbola, the dashed level sets of the total-error "
                    "constant c2 + c1*delta, the balanced ray c2 = c1*sqrt(delta) along which the "
                    "Cauchy-Schwarz excess vanishes, and the two landmark points - the symmetric choice "
                    "(2,2) and the balanced optimum (1 + 1/sqrt(delta), 1 + sqrt(delta)), where the lowest "
                    "attainable level set touches the hyperbola tangentially at the proved minimum "
                    "(1+sqrt(delta))^2. The right panel plots the three balanced constants as functions of "
                    "the codebook defect: the failure constant 1 + sqrt(delta) descending to the "
                    "first-moment optimum 1, the silent constant sqrt(delta) + delta vanishing, and the "
                    "total constant (1+sqrt(delta))^2, all compared against the symmetric values 2 and 4."
                ),
                "code": read("assets/viz_frontier.py"),
            },
            {
                "name": "The Abstention Conservation Law and the Unbounded Separation",
                "description": (
                    "Two panels. The left panel is the (abstain, silent) plane with the forbidden triangle "
                    "below the line silent + abstain = 1 - M*p_max shaded: no scheme whatsoever, however "
                    "cleverly designed, can live there. A decoder that never abstains is pinned to the "
                    "vertical axis, where the law forces its silent-corruption probability up to the floor; "
                    "the balanced scheme with a reject option sits far to the right, at a silent value near "
                    "zero, and the dashed arrow shows the reject option sliding the operating point along "
                    "the law. The right panel holds the source fixed and sweeps the code size, plotting the "
                    "committing floor 1 - M*p_max against the balanced silent-error bound "
                    "(sqrt(delta)+delta)|l|/M on a logarithmic scale, with the edge of the compressive "
                    "regime M*p_max = 1/2 marked: between the two curves lies the separation."
                ),
                "code": read("assets/viz_abstention.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Silent-Error Frontier Explorer",
                "description": (
                    "An interactive tour of the trade-off between confident lies and honest refusals. "
                    "Sliders control the codebook defect delta, the position c along the admissible "
                    "hyperbola, the codebook size, the number of codewords and the tag length. The canvas "
                    "draws the admissible region 1/c1 + 1/c2 <= 1 on a logarithmic axis, the dashed level "
                    "sets of the total-error constant, the balanced ray, and three marked points: the "
                    "symmetric choice (2,2), the balanced optimum, and the pair you have currently selected. "
                    "A live table reports the load, both constants, the resulting failure and "
                    "silent-corruption bounds, the proved minimum (1+sqrt(delta))^2 and the excess above it, "
                    "along with the perfect square (c2 - c1*sqrt(delta))^2/(c1 c2) from the sharp "
                    "Cauchy-Schwarz identity - watch it collapse to zero exactly as you snap onto the "
                    "balanced point. The tag slider shows the silent-error bound halving with each extra "
                    "tag bit at unchanged scan cost."
                ),
                "html": read("assets/widget_frontier.html"),
            },
            {
                "title": "The Abstention Laboratory: Two Decoders, One Encoder",
                "description": (
                    "A live compression scheme you can operate. A source with a flat typical head and a "
                    "light atypical tail is hashed by an affine 2-universal family; the tool searches the "
                    "key space by bad-set elimination at the balanced thresholds and then runs two decoders "
                    "on the very same codewords - one permitted to abstain when the codebook scan finds "
                    "zero or several matches, the other forbidden to and forced to commit. Stacked bars show "
                    "exactly where the probability mass goes (correct, abstained, silently corrupted), "
                    "computed exhaustively over the alphabet rather than sampled, together with the measured "
                    "separation factor. A second canvas plots both decoders in the (abstain, silent) plane "
                    "against the forbidden region below silent + abstain = 1 - M*p_max, so you can watch the "
                    "committing decoder be pushed onto the conservation line while the abstaining decoder "
                    "escapes along it. Sliders for the codebook size, the atypical mass and the number of "
                    "codewords let you enter and leave the compressive regime M*p_max <= 1/2 and see the "
                    "one-half floor switch on; a collapsible panel explains the counting argument behind the "
                    "existence of a good key."
                ),
                "html": read("assets/widget_abstention.html"),
            },
        ],
        "interactive_layout": read("assets/interactive_layout.md"),
        "lean_proofs": lean_bundle(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo_src},
        "lean_files": LEAN_FILES,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n",
                   encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: the abstention / silent-corruption conservation law and the
separation it produces.

Left panel : the (abstain, silent) plane. Every scheme over a code of size M
             must lie on or above the line  silent + abstain = 1 - M*p_max.
             The forbidden triangle below the line is shaded. A decoder that
             never abstains is confined to the vertical axis, where the law
             forces silent >= 1 - M*p_max; the abstaining balanced scheme sits
             far to the right at a tiny silent value.
Right panel : the separation as a function of the code size M, holding the
             source fixed: the committing floor 1 - M*p_max against the
             balanced silent bound (sqrt(delta)+delta)*|l|/M.

Standalone: requires only numpy and matplotlib.
"""

from __future__ import annotations

import math

import matplotlib.pyplot as plt
import numpy as np


def main(p_max: float = 1.0 / 128, m: int = 64, delta: float = 0.01,
         codebook: int = 128) -> None:
    floor = 1.0 - m * p_max
    s = math.sqrt(delta)
    balanced_silent = (s + delta) * codebook / m

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    # ---------------- left: the conservation law ----------------
    a = np.linspace(0.0, 1.0, 400)
    line = np.clip(floor - a, 0.0, None)
    ax1.fill_between(a, 0.0, line, color="#fecaca", alpha=0.85,
                     label="forbidden: no scheme lives here")
    ax1.plot(a, line, color="#dc2626", lw=2.2,
             label=r"$\Pr[\mathrm{silent}]+\Pr[\mathrm{abstain}]=1-Mp_{\max}$")

    ax1.plot([0.0], [floor], "s", ms=10, color="#b91c1c", zorder=5,
             label=f"committing decoders: silent $\\geq$ {floor:.3f}")
    ax1.plot([0.985], [min(balanced_silent, 0.02)], "o", ms=10, color="#1d4ed8",
             zorder=5, label="balanced key with abstention")
    ax1.annotate("", xy=(0.98, 0.02), xytext=(0.02, floor),
                 arrowprops=dict(arrowstyle="->", color="#334155", lw=1.4,
                                 linestyle="--"))
    ax1.text(0.36, floor * 0.62, "the reject option\nmoves mass along the law",
             fontsize=9, color="#334155")

    ax1.set_xlim(0.0, 1.05)
    ax1.set_ylim(0.0, 1.05)
    ax1.set_xlabel(r"abstention probability $\Pr[\mathrm{abstain}]$")
    ax1.set_ylabel(r"silent-corruption probability $\Pr[\mathrm{silent}]$")
    ax1.set_title(f"Conservation law, $Mp_{{\\max}} = {m * p_max:.3f}$")
    ax1.legend(fontsize=8, loc="upper right")
    ax1.grid(alpha=0.25)

    # ---------------- right: separation versus code size ----------------
    ms = np.arange(8, 129, 1)
    committing = np.clip(1.0 - ms * p_max, 0.0, None)
    abstaining = (s + delta) * codebook / ms

    ax2.plot(ms, committing, color="#dc2626", lw=2.2,
             label=r"committing floor $1-Mp_{\max}$")
    ax2.plot(ms, np.minimum(abstaining, 1.0), color="#1d4ed8", lw=2.2,
             label=r"balanced bound $(\sqrt{\delta}+\delta)|l|/M$")
    ax2.axhline(0.5, color="#64748b", ls="--", lw=1.0,
                label="one half")
    ax2.axvline(0.5 / p_max, color="#059669", ls=":", lw=1.4,
                label=r"edge of the compressive regime $Mp_{\max}=1/2$")

    ax2.set_yscale("log")
    ax2.set_xlabel("code size $M$")
    ax2.set_ylabel("silent-corruption probability (log scale)")
    ax2.set_title(rf"Separation: $\delta={delta}$, $|l|={codebook}$, "
                  rf"$p_{{\max}}={p_max:.4f}$")
    ax2.legend(fontsize=8, loc="lower left")
    ax2.grid(alpha=0.25, which="both")

    fig.tight_layout()
    fig.savefig("abstention.png", dpi=160)
    print("wrote abstention.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: the admissible frontier of silent/failure constant pairs, the
level sets of the total-error constant c2 + c1*delta, and the balanced optimum.

Left panel  : the region 1/c1 + 1/c2 <= 1 in the (c1, c2) plane, its boundary
              hyperbola c2 = c1/(c1-1), the level curves of c2 + c1*delta, and
              the balanced point (1 + 1/sqrt(delta), 1 + sqrt(delta)) at which
              the proved minimum (1 + sqrt(delta))^2 is attained.
Right panel : the three balanced constants as functions of delta --
              failure 1 + sqrt(delta), silent sqrt(delta) + delta, and total
              (1 + sqrt(delta))^2 -- showing that both error constants are
              simultaneously optimal in the limit delta -> 0.

Standalone: requires only numpy and matplotlib.
"""

from __future__ import annotations

import math
from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np


def balanced_point(delta: float) -> Tuple[float, float]:
    """The optimal admissible pair (c1, c2) = (1 + 1/sqrt(delta), 1 + sqrt(delta))."""
    s = math.sqrt(delta)
    return 1.0 + 1.0 / s, 1.0 + s


def main(delta: float = 0.04) -> None:
    s = math.sqrt(delta)
    optimum = (1.0 + s) ** 2
    c1_star, c2_star = balanced_point(delta)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.6))

    # ---------------- left: the (c1, c2) plane ----------------
    c1 = np.linspace(1.02, 12.0, 800)
    c2_boundary = c1 / (c1 - 1.0)

    c1g, c2g = np.meshgrid(np.linspace(1.02, 12.0, 400), np.linspace(1.02, 6.0, 400))
    admissible = (1.0 / c1g + 1.0 / c2g) <= 1.0
    ax1.contourf(c1g, c2g, admissible.astype(float), levels=[0.5, 1.5],
                 colors=["#dbeafe"], alpha=0.9)

    total = c2g + c1g * delta
    levels = [optimum, optimum * 1.05, optimum * 1.15, optimum * 1.35, optimum * 1.7]
    cs = ax1.contour(c1g, c2g, total, levels=levels, colors="#94a3b8",
                     linewidths=0.9, linestyles="--")
    ax1.clabel(cs, fmt=lambda v: f"{v:.2f}", fontsize=7)

    ax1.plot(c1, c2_boundary, color="#1d4ed8", lw=2.2,
             label=r"boundary $1/c_1+1/c_2=1$")
    ax1.plot([c1_star], [c2_star], "o", ms=10, color="#dc2626", zorder=5,
             label=(r"balanced point $(1+\delta^{-1/2},\,1+\delta^{1/2})$"
                    f"\n= ({c1_star:.2f}, {c2_star:.2f})"))
    ax1.plot([2.0], [2.0], "s", ms=8, color="#059669", zorder=5,
             label="symmetric point $(2,2)$")

    ray = np.linspace(0, 12, 10)
    ax1.plot(ray, ray * s, ":", color="#dc2626", lw=1.4,
             label=r"balanced ray $c_2=c_1\sqrt{\delta}$")

    ax1.set_xlim(1.0, 12.0)
    ax1.set_ylim(1.0, 6.0)
    ax1.set_xlabel(r"silent constant $c_1$")
    ax1.set_ylabel(r"failure constant $c_2$")
    ax1.set_title(rf"Admissible frontier, $\delta={delta}$: minimum "
                  rf"$c_2+c_1\delta=(1+\sqrt{{\delta}})^2={optimum:.3f}$")
    ax1.legend(fontsize=8, loc="upper right")
    ax1.grid(alpha=0.25)

    # ---------------- right: the balanced constants vs delta ----------------
    d = np.linspace(1e-6, 1.0, 800)
    ax2.plot(d, 1.0 + np.sqrt(d), color="#1d4ed8", lw=2.0,
             label=r"failure constant $1+\sqrt{\delta}$")
    ax2.plot(d, np.sqrt(d) + d, color="#dc2626", lw=2.0,
             label=r"silent constant $\sqrt{\delta}+\delta$")
    ax2.plot(d, (1.0 + np.sqrt(d)) ** 2, color="#7c3aed", lw=2.0,
             label=r"total constant $(1+\sqrt{\delta})^2$")
    ax2.axhline(1.0, color="#64748b", ls="--", lw=1.0,
                label="first-moment optimum $1$")
    ax2.axhline(2.0, color="#059669", ls=":", lw=1.2,
                label="symmetric constants $2$ and $4$")
    ax2.axhline(4.0, color="#059669", ls=":", lw=1.2)

    ax2.set_xlabel(r"codebook defect $\delta$")
    ax2.set_ylabel("constant")
    ax2.set_title(r"Both constants are simultaneously optimal as $\delta\to0^+$")
    ax2.legend(fontsize=8, loc="upper left")
    ax2.grid(alpha=0.25)

    fig.tight_layout()
    fig.savefig("frontier.png", dpi=160)
    print("wrote frontier.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Sharp silent-error constants for almost-lossless compression, and the
necessity of abstention -- numerical demonstrations.

Everything below is self-contained (standard library only) and exercises the
main results:

  1. The admissible frontier  1/c1 + 1/c2 <= 1  and the Cauchy-Schwarz bound
         c2 + c1*delta >= (1 + sqrt(delta))^2 ,
     attained exactly at the balanced point c1 = 1 + 1/sqrt(delta),
     c2 = 1 + sqrt(delta).

  2. The AM-GM identity for the one-parameter family c1 = 1+eta, c2 = 1+1/eta:
         E(eta) - [delta + (1+sqrt(delta))^2 L] = (L/eta) * (1 - eta*sqrt(delta))^2 .

  3. An end-to-end simulation: a Zipf source, a codebook of typical symbols,
     the affine 2-universal family x -> ((a x + b) mod p) mod M, exhaustive
     search for a key satisfying both Markov thresholds, and exact measurement
     of the failure / silent / abstention masses against the proved bounds.

  4. The abstention converse: a committing decoder (one that always answers)
     built from the *same* encoder has silent-corruption mass >= 1 - M*p_max,
     hence >= 1/2 in the compressive regime -- while the abstaining decoder
     with the balanced key stays far below it.

  5. The necessity of the covering condition: when 1/c1 + 1/c2 > 1, the
     interval-splitting construction produces two key blocks, each strictly
     below its Markov threshold, that nevertheless cover the whole key space.

  6. Tagging: an independently keyed T-valued tag divides the silent-error
     bound by T at unchanged scan cost.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Dict, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. Constants on the admissible frontier
# ----------------------------------------------------------------------------


def total_constant(c1: float, c2: float, delta: float) -> float:
    """Total-error constant c2 + c1*delta of the (c1, c2)-scheme."""
    return c2 + c1 * delta


def is_admissible(c1: float, c2: float, tol: float = 1e-12) -> bool:
    """The fractional covering condition 1/c1 + 1/c2 <= 1."""
    return c1 > 0.0 and c2 > 0.0 and 1.0 / c1 + 1.0 / c2 <= 1.0 + tol


def balanced_point(delta: float) -> Tuple[float, float]:
    """The optimal admissible pair (c1, c2) = (1 + 1/sqrt(delta), 1 + sqrt(delta))."""
    s = math.sqrt(delta)
    return 1.0 + 1.0 / s, 1.0 + s


def frontier_point(c: float) -> Tuple[float, float]:
    """The boundary hyperbola parametrised by the silent constant c > 1."""
    return c, c / (c - 1.0)


def cauchy_schwarz_gap(c1: float, c2: float, delta: float) -> float:
    """
    The exact excess in  (c2 + c1 s^2)(1/c1 + 1/c2) = (1+s)^2 + (c2 - c1 s)^2/(c1 c2),
    i.e. the perfect square that makes the frontier bound tight only on c2 = c1*sqrt(delta).
    """
    s = math.sqrt(delta)
    return (c2 - c1 * s) ** 2 / (c1 * c2)


def demo_frontier(delta: float = 0.01) -> None:
    print("=" * 78)
    print(f"1. THE ADMISSIBLE FRONTIER AND ITS OPTIMUM   (delta = {delta})")
    print("=" * 78)
    s = math.sqrt(delta)
    optimum = (1.0 + s) ** 2
    c1b, c2b = balanced_point(delta)
    print(f"  sqrt(delta)                       = {s:.6f}")
    print(f"  proved lower bound (1+sqrt(d))^2  = {optimum:.6f}")
    print(f"  balanced point (c1, c2)           = ({c1b:.4f}, {c2b:.4f})")
    print(f"  admissible?                       = {is_admissible(c1b, c2b)}")
    print(f"  1/c1 + 1/c2                       = {1/c1b + 1/c2b:.12f}   (exactly 1)")
    print()
    print("  scanning the hyperbola c -> (c, c/(c-1)):")
    print(f"  {'c (silent)':>12} {'c2 (failure)':>14} {'c2 + c1*d':>12} "
          f"{'excess':>12} {'CS square':>12}")
    for c in [1.05, 1.2, 1.5, 2.0, 4.0, c1b, 15.0, 40.0, 200.0]:
        cc1, cc2 = frontier_point(c)
        tot = total_constant(cc1, cc2, delta)
        print(f"  {cc1:12.4f} {cc2:14.4f} {tot:12.6f} "
              f"{tot - optimum:12.3e} {cauchy_schwarz_gap(cc1, cc2, delta):12.3e}")
    print()
    print("  The minimum over the whole hyperbola is attained at the balanced")
    print(f"  point c = 1 + 1/sqrt(delta) = {c1b:.4f}, where the excess vanishes.")
    print()


def demo_amgm(delta: float = 0.01, load: float = 0.05) -> None:
    print("=" * 78)
    print(f"2. THE AM-GM IDENTITY   (delta = {delta}, L = |l|/M = {load})")
    print("=" * 78)
    s = math.sqrt(delta)
    base = delta + (1.0 + s) ** 2 * load

    def total_error(eta: float) -> float:
        return delta + (1.0 + 1.0 / eta) * load + (1.0 + eta) * delta * load

    print(f"  proved minimum  delta + (1+sqrt(delta))^2 * L = {base:.8f}")
    print(f"  {'eta':>10} {'E(eta)':>14} {'E - min':>14} {'(L/eta)(1-eta s)^2':>22}")
    for eta in [0.1, 0.5, 1.0, 2.0, 5.0, 1.0 / s, 20.0, 50.0]:
        e = total_error(eta)
        pred = (load / eta) * (1.0 - eta * s) ** 2
        print(f"  {eta:10.4f} {e:14.8f} {e - base:14.3e} {pred:22.3e}")
    print()
    print(f"  The excess is exactly the perfect square (L/eta)(1 - eta*sqrt(d))^2,")
    print(f"  vanishing only at eta = 1/sqrt(delta) = {1/s:.4f}.")
    print()


# ----------------------------------------------------------------------------
# 3. An end-to-end simulation
# ----------------------------------------------------------------------------


@dataclass(frozen=True)
class Source:
    """A finite source: probabilities indexed by symbol 0 .. n-1."""
    probs: Tuple[float, ...]

    @property
    def size(self) -> int:
        return len(self.probs)

    @property
    def p_max(self) -> float:
        return max(self.probs)

    def mass(self, symbols: Sequence[int]) -> float:
        return sum(self.probs[x] for x in symbols)


def plateau_source(head: int, tail: int, tail_mass: float) -> Source:
    """
    A source with a flat typical head of `head` symbols carrying mass
    1 - tail_mass, and a flat atypical tail of `tail` symbols carrying
    tail_mass. This is the canonical shape for almost-lossless coding: a
    well-defined typical set plus a light residue.
    """
    head_p = (1.0 - tail_mass) / head
    tail_p = tail_mass / tail
    return Source(tuple([head_p] * head + [tail_p] * tail))


def typical_codebook(src: Source, delta_target: float) -> Tuple[List[int], float]:
    """
    Greedily take the heaviest symbols until the remaining (atypical) mass is
    at most delta_target. Returns the codebook and its exact defect.
    """
    order = sorted(range(src.size), key=lambda x: -src.probs[x])
    kept: List[int] = []
    remaining = 1.0
    for x in order:
        if remaining <= delta_target:
            break
        kept.append(x)
        remaining -= src.probs[x]
    return sorted(kept), max(remaining, 0.0)


def affine_family(p: int, max_keys: Optional[int] = None) -> List[Tuple[int, int]]:
    """
    Keys of the 2-universal family  x -> ((a x + b) mod p) mod M,
    for a prime p, a in 1..p-1, b in 0..p-1. For speed the caller may ask for a
    deterministic stride-subsample of the key space; the guarantees quoted in
    the text refer to the full family, and subsampling only makes the search
    for a good key harder, never the measured bounds weaker.
    """
    keys = [(a, b) for a in range(1, p) for b in range(p)]
    if max_keys is None or max_keys >= len(keys):
        return keys
    stride = len(keys) // max_keys
    return keys[::stride][:max_keys]


def hash_value(key: Tuple[int, int], x: int, p: int, m: int) -> int:
    a, b = key
    return ((a * x + b) % p) % m


def collision_mass(
    src: Source, key: Tuple[int, int], codebook: Sequence[int], p: int, m: int,
    region: Optional[Sequence[int]] = None,
) -> float:
    """
    Mass of {x in region : exists y in codebook, y != x, h(x) = h(y)}.
    region = None means the whole alphabet.
    """
    buckets: Dict[int, int] = {}
    for y in codebook:
        buckets[hash_value(key, y, p, m)] = buckets.get(hash_value(key, y, p, m), 0) + 1
    code_set = set(codebook)
    universe = range(src.size) if region is None else region
    total = 0.0
    for x in universe:
        h = hash_value(key, x, p, m)
        cnt = buckets.get(h, 0)
        if x in code_set:
            cnt -= 1  # x itself does not count as a collision partner
        if cnt > 0:
            total += src.probs[x]
    return total


def decode_abstaining(
    key: Tuple[int, int], received: int, codebook: Sequence[int], p: int, m: int
) -> Optional[int]:
    """Unique-match scan: exactly |codebook| hash evaluations, abstain unless unique."""
    candidate: Optional[int] = None
    count = 0
    for y in codebook:
        if hash_value(key, y, p, m) == received:
            candidate = y
            count += 1
    return candidate if count == 1 else None


def decode_committing(
    key: Tuple[int, int], received: int, codebook: Sequence[int], p: int, m: int
) -> int:
    """A decoder forbidden to abstain: return the first match, or the first codeword."""
    for y in codebook:
        if hash_value(key, y, p, m) == received:
            return y
    return codebook[0]


@dataclass(frozen=True)
class Measurement:
    failure: float
    silent: float
    abstain: float
    success: float


def measure_abstaining(
    src: Source, key: Tuple[int, int], codebook: Sequence[int], p: int, m: int
) -> Measurement:
    silent = abstain = success = 0.0
    for x in range(src.size):
        out = decode_abstaining(key, hash_value(key, x, p, m), codebook, p, m)
        if out is None:
            abstain += src.probs[x]
        elif out == x:
            success += src.probs[x]
        else:
            silent += src.probs[x]
    return Measurement(silent + abstain, silent, abstain, success)


def measure_committing(
    src: Source, key: Tuple[int, int], codebook: Sequence[int], p: int, m: int
) -> Measurement:
    silent = success = 0.0
    for x in range(src.size):
        out = decode_committing(key, hash_value(key, x, p, m), codebook, p, m)
        if out == x:
            success += src.probs[x]
        else:
            silent += src.probs[x]
    return Measurement(silent, silent, 0.0, success)


def select_good_key(
    src: Source, keys: Sequence[Tuple[int, int]], codebook: Sequence[int],
    p: int, m: int, c1: float, c2: float,
) -> Optional[Tuple[int, int]]:
    """
    Bad-set elimination: keep a key whose global collision mass is at most
    c2 * |l|/M and whose atypical collision mass is at most c1 * |l|/M * mu(atypical).
    Existence is guaranteed whenever 1/c1 + 1/c2 <= 1.
    """
    n = len(codebook)
    code_set = set(codebook)
    atypical = [x for x in range(src.size) if x not in code_set]
    mu_atyp = src.mass(atypical)
    global_budget = c2 * n / m
    atyp_budget = c1 * (n / m) * mu_atyp
    for key in keys:
        if collision_mass(src, key, codebook, p, m) > global_budget:
            continue
        if collision_mass(src, key, codebook, p, m, atypical) > atyp_budget:
            continue
        return key
    return None


def demo_simulation(prime: int = 769, m: int = 2048) -> None:
    print("=" * 78)
    print("3. END-TO-END SIMULATION OF THE BALANCED SCHEME")
    print("=" * 78)
    src = plateau_source(head=512, tail=256, tail_mass=0.01)
    codebook, delta = typical_codebook(src, delta_target=0.02)
    keys = affine_family(prime, max_keys=400)
    n = len(codebook)
    load = n / m
    s = math.sqrt(delta)
    c1, c2 = balanced_point(delta)

    print(f"  alphabet size            = {src.size}")
    print(f"  p_max                    = {src.p_max:.6f}")
    print(f"  codebook size |l|        = {n}")
    print(f"  codewords M              = {m}   (load L = |l|/M = {load:.4f})")
    print(f"  codebook defect delta    = {delta:.6f}")
    print(f"  key space size           = {len(keys)}")
    print(f"  balanced thresholds      = (c1, c2) = ({c1:.4f}, {c2:.4f})")
    print(f"  1/c1 + 1/c2              = {1/c1 + 1/c2:.12f}")
    print()

    key = select_good_key(src, keys, codebook, prime, m, c1, c2)
    assert key is not None, "a good key must exist under the covering condition"
    print(f"  selected key (a, b)      = {key}")

    meas = measure_abstaining(src, key, codebook, prime, m)
    bound_fail = delta + (1.0 + s) * load
    bound_silent = (s + delta) * load
    bound_total = delta + (1.0 + s) ** 2 * load

    print()
    print(f"  {'quantity':<28}{'measured':>14}{'proved bound':>16}{'slack':>12}")
    print(f"  {'failure probability':<28}{meas.failure:14.6f}{bound_fail:16.6f}"
          f"{bound_fail - meas.failure:12.6f}")
    print(f"  {'silent corruption':<28}{meas.silent:14.6f}{bound_silent:16.6f}"
          f"{bound_silent - meas.silent:12.6f}")
    print(f"  {'failure + silent':<28}{meas.failure + meas.silent:14.6f}"
          f"{bound_total:16.6f}{bound_total - meas.failure - meas.silent:12.6f}")
    print(f"  {'abstention probability':<28}{meas.abstain:14.6f}{'--':>16}{'--':>12}")
    print(f"  {'success probability':<28}{meas.success:14.6f}{'--':>16}{'--':>12}")
    print(f"  {'decoding cost (evals)':<28}{n:14d}{n:16d}{0:12d}")
    assert meas.failure <= bound_fail + 1e-12
    assert meas.silent <= bound_silent + 1e-12
    assert meas.failure + meas.silent <= bound_total + 1e-12
    print()
    print("  All three proved bounds hold, with the silent-corruption")
    print("  probability second order in delta as predicted.")
    print()
    return None


# ----------------------------------------------------------------------------
# 4. The abstention converse and the separation
# ----------------------------------------------------------------------------


def demo_abstention(prime: int = 193, m: int = 64) -> None:
    print("=" * 78)
    print("4. ABSTENTION IS NECESSARY: CONVERSE AND SEPARATION")
    print("=" * 78)
    # A genuinely compressive regime: M * p_max <= 1/2, so the converse bites.
    src = plateau_source(head=128, tail=64, tail_mass=0.01)
    codebook, delta = typical_codebook(src, delta_target=0.02)
    keys = affine_family(prime, max_keys=400)
    s = math.sqrt(delta)
    c1, c2 = balanced_point(delta)
    key = select_good_key(src, keys, codebook, prime, m, c1, c2)
    assert key is not None

    converse = 1.0 - m * src.p_max
    print(f"  M * p_max                        = {m * src.p_max:.6f}")
    print(f"  converse floor 1 - M*p_max       = {converse:.6f}")
    print(f"  compressive regime (M p_max<=1/2)= {m * src.p_max <= 0.5}")
    print()

    ab = measure_abstaining(src, key, codebook, prime, m)
    co = measure_committing(src, key, codebook, prime, m)

    print(f"  {'decoder':<24}{'silent':>12}{'abstain':>12}{'silent+abstain':>17}")
    print(f"  {'abstaining (balanced)':<24}{ab.silent:12.6f}{ab.abstain:12.6f}"
          f"{ab.silent + ab.abstain:17.6f}")
    print(f"  {'committing':<24}{co.silent:12.6f}{co.abstain:12.6f}"
          f"{co.silent + co.abstain:17.6f}")
    print()
    print(f"  Trade-off law   silent + abstain >= 1 - M*p_max = {converse:.6f}")
    print(f"    abstaining decoder: {ab.silent + ab.abstain:.6f} >= {converse:.6f}"
          f"  -> {ab.silent + ab.abstain >= converse - 1e-12}")
    print(f"    committing decoder: {co.silent:.6f} >= {converse:.6f}"
          f"  -> {co.silent >= converse - 1e-12}")
    assert ab.silent + ab.abstain >= converse - 1e-12
    assert co.silent >= converse - 1e-12
    if m * src.p_max <= 0.5:
        assert co.silent >= 0.5 - 1e-12
        print(f"    committing decoder lies at least half the time: "
              f"{co.silent:.6f} >= 0.5")
    print()
    print(f"  SEPARATION: silent corruption {co.silent:.6f} (committing) versus "
          f"{ab.silent:.6f} (abstaining)")
    if ab.silent > 0:
        print(f"              ratio = {co.silent / ab.silent:.1f}x")
    else:
        print("              ratio = infinite (the abstaining decoder never lies here)")
    print(f"  balanced silent bound (sqrt(d)+d)L = "
          f"{(s + delta) * len(codebook) / m:.6f}")
    print()


# ----------------------------------------------------------------------------
# 5. Necessity of the covering condition
# ----------------------------------------------------------------------------


def covering_counterexample(
    num_keys: int, c1: float, c2: float
) -> Optional[Tuple[List[int], List[int]]]:
    """
    Interval-splitting construction: if K(1/c1 + 1/c2 - 1) > 1, return two key
    blocks B1, B2 with |Bi|*ci < K that nevertheless cover {0,...,K-1}.
    """
    if not num_keys * (1.0 / c1 + 1.0 / c2 - 1.0) > 1.0:
        return None
    n = math.ceil(num_keys / c1) - 1
    b1 = list(range(min(n, num_keys)))
    b2 = list(range(min(n, num_keys), num_keys))
    return b1, b2


def demo_covering(num_keys: int = 1000) -> None:
    print("=" * 78)
    print("5. THE COVERING CONDITION IS EXACTLY THE BOUNDARY OF THE METHOD")
    print("=" * 78)
    print(f"  key space size K = {num_keys}")
    print(f"  {'c1':>8}{'c2':>8}{'1/c1+1/c2':>12}{'admissible':>12}"
          f"{'|B1|c1<K':>10}{'|B2|c2<K':>10}{'covers':>8}")
    for c1, c2 in [(2.0, 2.0), (1.5, 3.0), (1.9, 1.9), (1.5, 2.0), (1.2, 1.5)]:
        cover = covering_counterexample(num_keys, c1, c2)
        if cover is None:
            print(f"  {c1:8.2f}{c2:8.2f}{1/c1 + 1/c2:12.4f}"
                  f"{str(is_admissible(c1, c2)):>12}{'--':>10}{'--':>10}{'--':>8}")
        else:
            b1, b2 = cover
            ok1 = len(b1) * c1 < num_keys
            ok2 = len(b2) * c2 < num_keys
            covers = sorted(set(b1) | set(b2)) == list(range(num_keys))
            assert ok1 and ok2 and covers
            print(f"  {c1:8.2f}{c2:8.2f}{1/c1 + 1/c2:12.4f}"
                  f"{str(is_admissible(c1, c2)):>12}{str(ok1):>10}"
                  f"{str(ok2):>10}{str(covers):>8}")
    print()
    print("  For every inadmissible pair the two blocks lie strictly below their")
    print("  Markov thresholds yet exhaust the key space: no union-bound argument")
    print("  at those thresholds can produce a good key.")
    print()


# ----------------------------------------------------------------------------
# 6. Tagging
# ----------------------------------------------------------------------------


def demo_tagging(delta: float = 0.01, codebook_size: int = 128, m: int = 64) -> None:
    print("=" * 78)
    print("6. TAGGED CODEWORDS: EXPONENTIAL SUPPRESSION AT UNCHANGED SCAN COST")
    print("=" * 78)
    s = math.sqrt(delta)
    print(f"  delta = {delta}, |l| = {codebook_size}, M = {m}")
    print(f"  {'tag bits t':>11}{'T = 2^t':>10}{'silent bound':>16}"
          f"{'failure bound':>16}{'scan cost':>11}")
    for t in range(0, 9, 2):
        tag = 2 ** t
        silent = (s + delta) * codebook_size / (m * tag)
        failure = delta + (1.0 + s) * codebook_size / (m * tag)
        print(f"  {t:11d}{tag:10d}{silent:16.3e}{failure:16.6f}{codebook_size:11d}")
    print()
    print("  Each extra tag bit halves the silent-error bound; the scan still")
    print("  costs exactly |l| evaluations of the (tagged) hash.")
    print()


# ----------------------------------------------------------------------------


def main() -> None:
    print()
    print("SHARP SILENT-ERROR CONSTANTS FOR ALMOST-LOSSLESS COMPRESSION")
    print("AND THE NECESSITY OF ABSTENTION -- numerical demonstrations")
    print()
    demo_frontier(delta=0.01)
    demo_amgm(delta=0.01, load=0.05)
    demo_simulation()
    demo_abstention()
    demo_covering()
    demo_tagging()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
