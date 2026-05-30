#!/usr/bin/env python3
"""
Algorithms for Higher-Order Rewriting and Confluence Analysis

Implements the core algorithms from the research paper on unbounded
confluence via well-founded overlap induction.
"""

from dataclasses import dataclass, field
from typing import List, Optional, Set, Tuple, Dict, Callable
from enum import Enum
import itertools


# =============================================================================
# Data Structures
# =============================================================================

class TermKind(Enum):
    VAR = "var"
    APP = "app"
    LAM = "lam"


@dataclass
class HOTerm:
    """
    Higher-order term in the simply-typed lambda calculus.

    Representation uses de Bruijn indices for bound variables:
    - var(i): variable with index i
    - app(s, t): application of s to t
    - lam(body): lambda abstraction binding index 0 in body
    """
    kind: TermKind
    var_idx: Optional[int] = None
    left: Optional['HOTerm'] = None
    right: Optional['HOTerm'] = None
    body: Optional['HOTerm'] = None

    @staticmethod
    def var(i: int) -> 'HOTerm':
        return HOTerm(TermKind.VAR, var_idx=i)

    @staticmethod
    def app(s: 'HOTerm', t: 'HOTerm') -> 'HOTerm':
        return HOTerm(TermKind.APP, left=s, right=t)

    @staticmethod
    def lam(body: 'HOTerm') -> 'HOTerm':
        return HOTerm(TermKind.LAM, body=body)

    def size(self) -> int:
        """Syntactic size of the term."""
        if self.kind == TermKind.VAR:
            return 1
        elif self.kind == TermKind.APP:
            return 1 + self.left.size() + self.right.size()
        else:
            return 1 + self.body.size()

    def depth(self) -> int:
        """Nesting depth of the term."""
        if self.kind == TermKind.VAR:
            return 0
        elif self.kind == TermKind.APP:
            return 1 + max(self.left.depth(), self.right.depth())
        else:
            return 1 + self.body.depth()

    def complexity(self) -> Tuple[int, int]:
        """TermComplexity: (size, depth) ordered lexicographically."""
        return (self.size(), self.depth())

    def subterms(self) -> List['HOTerm']:
        """All subterms including the term itself."""
        result = [self]
        if self.kind == TermKind.APP:
            result.extend(self.left.subterms())
            result.extend(self.right.subterms())
        elif self.kind == TermKind.LAM:
            result.extend(self.body.subterms())
        return result

    def is_closed_at(self, depth: int = 0) -> bool:
        """Check if the term is closed (no free variables) at given depth."""
        if self.kind == TermKind.VAR:
            return self.var_idx < depth
        elif self.kind == TermKind.APP:
            return self.left.is_closed_at(depth) and self.right.is_closed_at(depth)
        else:
            return self.body.is_closed_at(depth + 1)

    def is_closed(self) -> bool:
        return self.is_closed_at(0)

    def rename(self, rho: Callable[[int], int]) -> 'HOTerm':
        """Apply a renaming to the term."""
        if self.kind == TermKind.VAR:
            return HOTerm.var(rho(self.var_idx))
        elif self.kind == TermKind.APP:
            return HOTerm.app(self.left.rename(rho), self.right.rename(rho))
        else:
            lift_rho = lambda i: 0 if i == 0 else rho(i - 1) + 1
            return HOTerm.lam(self.body.rename(lift_rho))

    def subst(self, sigma: Callable[[int], 'HOTerm']) -> 'HOTerm':
        """Apply a substitution to the term."""
        if self.kind == TermKind.VAR:
            return sigma(self.var_idx)
        elif self.kind == TermKind.APP:
            return HOTerm.app(self.left.subst(sigma), self.right.subst(sigma))
        else:
            lift_sigma = lambda i: (
                HOTerm.var(0) if i == 0
                else sigma(i - 1).rename(lambda j: j + 1)
            )
            return HOTerm.lam(self.body.subst(lift_sigma))

    def beta_contract(self) -> Optional['HOTerm']:
        """Perform one step of β-reduction if possible."""
        if (self.kind == TermKind.APP and
            self.left.kind == TermKind.LAM):
            body = self.left.body
            arg = self.right
            sigma = lambda i: arg if i == 0 else HOTerm.var(i - 1)
            return body.subst(sigma)
        return None

    def __repr__(self) -> str:
        if self.kind == TermKind.VAR:
            return f"x{self.var_idx}"
        elif self.kind == TermKind.APP:
            return f"({self.left} {self.right})"
        else:
            return f"(λ.{self.body})"

    def __eq__(self, other):
        if not isinstance(other, HOTerm):
            return False
        if self.kind != other.kind:
            return False
        if self.kind == TermKind.VAR:
            return self.var_idx == other.var_idx
        elif self.kind == TermKind.APP:
            return self.left == other.left and self.right == other.right
        else:
            return self.body == other.body

    def __hash__(self):
        if self.kind == TermKind.VAR:
            return hash(("var", self.var_idx))
        elif self.kind == TermKind.APP:
            return hash(("app", self.left, self.right))
        else:
            return hash(("lam", self.body))


# =============================================================================
# Rewrite System
# =============================================================================

@dataclass
class Rule:
    """A rewrite rule: lhs → rhs."""
    lhs: HOTerm
    rhs: HOTerm
    name: str = ""

    def __repr__(self):
        return f"{self.name}: {self.lhs} → {self.rhs}"


@dataclass
class HoSystem:
    """A higher-order rewrite system."""
    rules: List[Rule]
    name: str = ""

    def max_lhs_size(self) -> int:
        if not self.rules:
            return 0
        return max(r.lhs.size() for r in self.rules)

    def critical_pair_bound(self) -> int:
        k = len(self.rules)
        M = self.max_lhs_size()
        return k * k * M * M


# =============================================================================
# Algorithm 1: Critical Pair Enumeration
# =============================================================================

def syntactic_match(pattern: HOTerm, term: HOTerm) -> bool:
    """
    Check if a pattern can potentially match a term.

    Time complexity: O(min(|pattern|, |term|))
    Space complexity: O(depth(pattern))
    """
    if pattern.kind == TermKind.VAR:
        return True  # Variables match anything
    if term.kind == TermKind.VAR:
        return True
    if pattern.kind != term.kind:
        return False
    if pattern.kind == TermKind.APP:
        return (syntactic_match(pattern.left, term.left) and
                syntactic_match(pattern.right, term.right))
    if pattern.kind == TermKind.LAM:
        return syntactic_match(pattern.body, term.body)
    return False


@dataclass
class CriticalPair:
    """A critical pair with metadata."""
    left: HOTerm
    right: HOTerm
    source_size: int
    rule1_name: str = ""
    rule2_name: str = ""


def enumerate_critical_pairs(system: HoSystem, max_size: int) -> List[CriticalPair]:
    """
    Enumerate all critical pairs of a system up to a given size bound.

    Algorithm:
    1. For each pair of rules (r1, r2)
    2. For each subterm s of r1.lhs
    3. If s can match r2.lhs and combined size ≤ max_size
    4. Generate the critical pair (r1.rhs, r2.rhs)

    Time complexity: O(k² · M · max_size) where k = |rules|, M = max LHS size
    Space complexity: O(k² · M) for storing pairs
    """
    pairs = []
    for r1 in system.rules:
        for r2 in system.rules:
            for sub in r1.lhs.subterms():
                if (syntactic_match(sub, r2.lhs) and
                    r1.lhs.size() + r2.lhs.size() <= max_size):
                    pairs.append(CriticalPair(
                        left=r1.rhs,
                        right=r2.rhs,
                        source_size=r1.lhs.size() + r2.lhs.size(),
                        rule1_name=r1.name,
                        rule2_name=r2.name
                    ))
    return pairs


# =============================================================================
# Algorithm 2: Bounded Normalization
# =============================================================================

def bounded_normalize(term: HOTerm, system: HoSystem, fuel: int = 100) -> HOTerm:
    """
    Normalize a term by repeatedly applying β-reduction and rewrite rules.

    Uses a fuel parameter to ensure termination even for non-terminating systems.

    Time complexity: O(fuel · |term| · k) per step where k = |rules|
    Space complexity: O(|term| · fuel) in the worst case
    """
    current = term
    for _ in range(fuel):
        # Try β-reduction first
        reduced = current.beta_contract()
        if reduced is not None:
            current = reduced
            continue

        # Try rewrite rules (very simplified — just top-level matching)
        changed = False
        for rule in system.rules:
            if current == rule.lhs:
                current = rule.rhs
                changed = True
                break
        if not changed:
            break

    return current


# =============================================================================
# Algorithm 3: Joinability Test
# =============================================================================

def try_join(t1: HOTerm, t2: HOTerm, system: HoSystem, fuel: int = 100) -> bool:
    """
    Test if two terms are joinable by normalizing both and comparing.

    Time complexity: O(fuel · max(|t1|, |t2|) · k)
    Space complexity: O(max(|t1|, |t2|) · fuel)

    Returns True if both terms normalize to the same term.
    """
    nf1 = bounded_normalize(t1, system, fuel)
    nf2 = bounded_normalize(t2, system, fuel)
    return nf1 == nf2


# =============================================================================
# Algorithm 4: Confluence Checker
# =============================================================================

def check_confluence_bounded(system: HoSystem, max_size: int) -> Tuple[bool, List[CriticalPair]]:
    """
    Check bounded confluence by enumerating and testing all critical pairs.

    Algorithm (Knuth-Bendix style):
    1. Enumerate all critical pairs up to size max_size
    2. For each pair, test joinability
    3. Return True if all pairs are joinable

    Time complexity: O(k² · M · max_size · fuel)
    Space complexity: O(k² · M)
    """
    pairs = enumerate_critical_pairs(system, max_size)
    non_joinable = []

    for cp in pairs:
        if not try_join(cp.left, cp.right, system):
            non_joinable.append(cp)

    return len(non_joinable) == 0, non_joinable


# =============================================================================
# Algorithm 5: Overlap Decomposition Analysis
# =============================================================================

def analyze_overlap_structure(system: HoSystem, max_depth: int = 5) -> Dict:
    """
    Analyze the overlap decomposition structure of a rewrite system.

    For each size bound N from 1 to max_depth, count the number of
    critical pairs and check joinability. The well-founded overlap
    decomposition property holds if the critical pair count stabilizes.

    Returns a dictionary with analysis results.
    """
    results = {
        "system_name": system.name,
        "num_rules": len(system.rules),
        "max_lhs_size": system.max_lhs_size(),
        "conjectured_bound": system.critical_pair_bound(),
        "by_size": []
    }

    for N in range(1, max_depth + 1):
        pairs = enumerate_critical_pairs(system, N)
        confluent, non_joinable = check_confluence_bounded(system, N)
        results["by_size"].append({
            "size_bound": N,
            "num_pairs": len(pairs),
            "all_joinable": confluent,
            "non_joinable_count": len(non_joinable)
        })

    return results


# =============================================================================
# Example Systems
# =============================================================================

def make_map_fusion_system() -> HoSystem:
    """Create the map fusion optimization system."""
    x0, x1, x2, x3 = HOTerm.var(0), HOTerm.var(1), HOTerm.var(2), HOTerm.var(3)

    map_fusion = Rule(
        lhs=HOTerm.app(HOTerm.app(x0, x1), HOTerm.app(HOTerm.app(x0, x2), x3)),
        rhs=HOTerm.app(
            HOTerm.app(x0, HOTerm.lam(HOTerm.app(x2, HOTerm.app(x3, HOTerm.var(0))))),
            x3
        ),
        name="map_fusion"
    )

    map_id = Rule(
        lhs=HOTerm.app(HOTerm.app(x0, HOTerm.lam(HOTerm.var(0))), x1),
        rhs=x1,
        name="map_id"
    )

    return HoSystem(rules=[map_fusion, map_id], name="MapFusion")


def make_identity_system() -> HoSystem:
    """Create a simple identity elimination system."""
    x0, x1 = HOTerm.var(0), HOTerm.var(1)

    id_elim = Rule(
        lhs=HOTerm.app(HOTerm.lam(HOTerm.var(0)), x0),
        rhs=x0,
        name="id_elim"
    )

    return HoSystem(rules=[id_elim], name="IdentityElim")


# =============================================================================
# Usage Example
# =============================================================================

if __name__ == "__main__":
    print("Higher-Order Rewriting Algorithms")
    print("=" * 50)
    print()

    # Create systems
    map_sys = make_map_fusion_system()
    id_sys = make_identity_system()

    for sys in [map_sys, id_sys]:
        print(f"System: {sys.name}")
        print(f"  Rules: {len(sys.rules)}")
        print(f"  Max LHS size: {sys.max_lhs_size()}")
        print(f"  Critical pair bound: {sys.critical_pair_bound()}")
        print()

        analysis = analyze_overlap_structure(sys, max_depth=10)
        print(f"  Overlap analysis by size bound:")
        for entry in analysis["by_size"]:
            status = "✓" if entry["all_joinable"] else "✗"
            print(f"    N={entry['size_bound']:>2}: "
                  f"{entry['num_pairs']:>3} pairs, "
                  f"{status} confluent")
        print()
