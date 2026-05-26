#!/usr/bin/env python3
"""
Algorithms for the Tensor Distributivity Rewrite System.

Implements the key algorithms from the research:
1. Distributivity potential computation (polynomial interpretation)
2. Canonical normalization (bottom-up with greedy root reduction)
3. AC-equivalence checking (via multiset canonicalization)
4. Critical pair enumeration
5. Confluence verification by exhaustive BFS
"""

from demo import (
    Expr, ScalVar, VecVar, MatVar, ScalAdd, ScalMul, VecAdd, MatAdd,
    SmulVec, SmulMat, MulVec, Dot,
    dist_potential, expr_size, root_rewrites, all_deep_rewrites,
    ac_canonical, ac_equiv, flatten_add, normalize_greedy, pretty,
    bfs_all_normal_forms
)
from typing import List, Tuple, Dict, Set, Optional
from collections import defaultdict


def verify_termination_measure(terms: List[Expr]) -> bool:
    """Verify that dist_potential strictly decreases for all one-step rewrites
    on the given list of terms.

    Args:
        terms: List of tensor expressions to check.

    Returns:
        True if all rewrites decrease the measure.

    Complexity: O(|terms| × max_rewrites_per_term)
    """
    for t in terms:
        dp_t = dist_potential(t)
        for name, result in all_deep_rewrites(t):
            dp_r = dist_potential(result)
            if dp_r >= dp_t:
                print(f"VIOLATION: {name} on {pretty(t)}: {dp_t} -> {dp_r}")
                return False
    return True


def enumerate_critical_pairs(
    svars: List[Expr], vvars: List[Expr], mvars: List[Expr]
) -> List[Tuple[str, Expr, List[Tuple[str, Expr]]]]:
    """Enumerate all root-level critical pairs.

    A critical pair occurs when two different root rewrite rules match
    the same term. Returns list of (description, term, [(rule, result)]).

    Complexity: O(|vars|^4) for terms with up to 4 subexpressions.
    """
    pairs = []

    # CP1: Rules 1&2 on mulVec (matAdd A B) (vecAdd v w)
    for A in mvars:
        for B in mvars:
            for v in vvars:
                for w in vvars:
                    t = MulVec(MatAdd(A, B), VecAdd(v, w))
                    rewrites = root_rewrites(t)
                    if len(rewrites) >= 2:
                        pairs.append(("R1&R2", t, rewrites))

    # CP2: Rules 1&3 on mulVec (smulMat a A) (vecAdd v w)
    for a in svars:
        for A in mvars:
            for v in vvars:
                for w in vvars:
                    t = MulVec(SmulMat(a, A), VecAdd(v, w))
                    rewrites = root_rewrites(t)
                    if len(rewrites) >= 2:
                        pairs.append(("R1&R3", t, rewrites))

    # CP3: Rules 6&7 on dot (vecAdd v w) (vecAdd v' w')
    for v in vvars:
        for w in vvars:
            for v2 in vvars:
                for w2 in vvars:
                    t = Dot(VecAdd(v, w), VecAdd(v2, w2))
                    rewrites = root_rewrites(t)
                    if len(rewrites) >= 2:
                        pairs.append(("R6&R7", t, rewrites))

    # CP4: Rules 7&8 on dot (smulVec a v) (vecAdd v' w')
    for a in svars:
        for v in vvars:
            for v2 in vvars:
                for w2 in vvars:
                    t = Dot(SmulVec(a, v), VecAdd(v2, w2))
                    rewrites = root_rewrites(t)
                    if len(rewrites) >= 2:
                        pairs.append(("R7&R8", t, rewrites))

    return pairs


def verify_confluence_exhaustive(
    terms: List[Expr], max_states: int = 1000
) -> Tuple[int, int, List[Tuple[Expr, Expr, Expr]]]:
    """Exhaustively verify confluence by BFS on all terms.

    For each term, computes all normal forms and checks pairwise
    AC-equivalence.

    Args:
        terms: Terms to check.
        max_states: Max BFS states per term.

    Returns:
        (terms_checked, terms_confluent, violations)
        where violations is a list of (term, nf1, nf2) triples.

    Complexity: O(|terms| × max_states × branching_factor)
    """
    checked = 0
    confluent = 0
    violations = []

    for t in terms:
        if not all_deep_rewrites(t):
            continue

        nfs, _, _ = bfs_all_normal_forms(t, max_states)
        checked += 1
        nf_list = list(nfs)

        is_confluent = True
        for i in range(len(nf_list)):
            for j in range(i + 1, len(nf_list)):
                if not ac_equiv(nf_list[i], nf_list[j]):
                    violations.append((t, nf_list[i], nf_list[j]))
                    is_confluent = False

        if is_confluent:
            confluent += 1

    return checked, confluent, violations


def normalization_statistics(terms: List[Expr]) -> Dict:
    """Compute normalization statistics for a collection of terms.

    Returns a dictionary with:
    - max_sequence_length: longest reduction sequence found
    - avg_sequence_length: average reduction sequence length
    - max_dp: maximum distributivity potential
    - dp_vs_length: list of (dp, max_seq_len) pairs

    Complexity: O(|terms| × max_states)
    """
    stats = {
        "max_sequence_length": 0,
        "avg_sequence_length": 0.0,
        "max_dp": 0,
        "dp_vs_length": [],
        "total_terms": 0,
    }

    total_len = 0
    count = 0

    for t in terms:
        if not all_deep_rewrites(t):
            continue

        dp = dist_potential(t)
        _, max_len, _ = bfs_all_normal_forms(t, max_states=500)
        count += 1
        total_len += max_len

        stats["max_sequence_length"] = max(stats["max_sequence_length"], max_len)
        stats["max_dp"] = max(stats["max_dp"], dp)
        stats["dp_vs_length"].append((dp, max_len))

    stats["total_terms"] = count
    stats["avg_sequence_length"] = total_len / count if count > 0 else 0
    return stats


if __name__ == "__main__":
    # Quick self-test
    svars = [ScalVar("α"), ScalVar("β")]
    vvars = [VecVar("v"), VecVar("w")]
    mvars = [MatVar("A"), MatVar("B")]

    print("Enumerating critical pairs...")
    pairs = enumerate_critical_pairs(svars, vvars, mvars)
    print(f"Found {len(pairs)} critical pair instances")

    for desc, term, rewrites in pairs[:4]:
        nfs = [normalize_greedy(r) for _, r in rewrites]
        all_ac = all(ac_equiv(nfs[0], nf) for nf in nfs[1:])
        print(f"  {desc}: {pretty(term)} → all AC-equiv: {all_ac}")

    print("\nVerifying termination measure...")
    test_terms = [
        MulVec(MatVar("A"), VecAdd(VecVar("v"), VecVar("w"))),
        Dot(SmulVec(ScalVar("a"), VecVar("v")), VecVar("w")),
        ScalMul(ScalVar("a"), ScalAdd(ScalVar("b"), ScalVar("c"))),
    ]
    print(f"  All decrease: {verify_termination_measure(test_terms)}")
