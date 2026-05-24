#!/usr/bin/env python3
"""
Many-Sorted Convergent Rewrite Optimizer — Core Algorithms

Implements the key algorithms underlying the many-sorted convergent rewrite framework:
1. ManySortedSignature: representation of typed operation symbols
2. ManySortedTerm: sort-indexed term trees
3. ManySortedNormalizer: convergent normalization engine
4. ManySortedAlgebra: semantic evaluation framework
"""

from dataclasses import dataclass, field
from typing import Any, Callable, Dict, List, Optional, Tuple, TypeVar
from enum import Enum
import time


# ─────────────────────────────────────────────────────────
# Algorithm 1: Many-Sorted Signature
# ─────────────────────────────────────────────────────────

@dataclass(frozen=True)
class SortedOp:
    """An operation symbol in a many-sorted signature.

    Attributes:
        name: Human-readable name
        arg_sorts: List of sorts for each argument
        result_sort: The sort of the result

    Time complexity: O(1) for all operations
    Space complexity: O(k) where k = arity
    """
    name: str
    arg_sorts: tuple  # tuple of sort values
    result_sort: Any   # sort value

    @property
    def arity(self) -> int:
        return len(self.arg_sorts)


class ManySortedSignature:
    """A many-sorted signature: a collection of sorts and typed operations.

    Example usage:
        sig = ManySortedSignature(sorts={'Scal', 'Vec'})
        sig.add_op(SortedOp('smul', ('Scal', 'Vec'), 'Vec'))
        sig.add_op(SortedOp('vAdd', ('Vec', 'Vec'), 'Vec'))

    Time complexity:
        add_op: O(1) amortized
        get_ops_by_result: O(1) after first call (cached)
    """
    def __init__(self, sorts: set):
        self.sorts = frozenset(sorts)
        self.ops: Dict[str, SortedOp] = {}
        self._ops_by_result: Optional[Dict[Any, List[SortedOp]]] = None

    def add_op(self, op: SortedOp):
        self.ops[op.name] = op
        self._ops_by_result = None  # invalidate cache

    def get_ops_by_result(self, sort) -> List[SortedOp]:
        if self._ops_by_result is None:
            self._ops_by_result = {}
            for op in self.ops.values():
                self._ops_by_result.setdefault(op.result_sort, []).append(op)
        return self._ops_by_result.get(sort, [])


# ─────────────────────────────────────────────────────────
# Algorithm 2: Many-Sorted Terms
# ─────────────────────────────────────────────────────────

@dataclass
class MSTerm:
    """A many-sorted term: either a variable or an operation application.

    Invariant: If op is not None, then:
      - len(children) == op.arity
      - children[i].sort == op.arg_sorts[i] for all i
      - self.sort == op.result_sort

    Time complexity:
        size: O(n) where n = number of nodes
        depth: O(n)
        __eq__: O(n)
    Space complexity: O(n)
    """
    sort: Any
    op: Optional[SortedOp] = None
    var_name: Optional[str] = None
    children: List['MSTerm'] = field(default_factory=list)

    def is_var(self) -> bool:
        return self.var_name is not None

    def size(self) -> int:
        return 1 + sum(c.size() for c in self.children)

    def depth(self) -> int:
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def __repr__(self):
        if self.is_var():
            return self.var_name
        if not self.children:
            return self.op.name
        args = ', '.join(repr(c) for c in self.children)
        return f"{self.op.name}({args})"


# ─────────────────────────────────────────────────────────
# Algorithm 3: Rewrite Rules and Normalization
# ─────────────────────────────────────────────────────────

@dataclass
class RewriteRule:
    """A many-sorted rewrite rule: lhs → rhs at a specific sort.

    Both lhs and rhs must have the same sort.
    Variables in rhs must be a subset of variables in lhs.

    Attributes:
        name: Human-readable rule name
        sort: The sort at which the rule operates
        lhs: Left-hand side pattern
        rhs: Right-hand side pattern
    """
    name: str
    sort: Any
    lhs: MSTerm
    rhs: MSTerm


class ManySortedNormalizer:
    """Convergent normalization engine for many-sorted terms.

    Applies rewrite rules bottom-up until no more rules apply.
    Assumes the rule set is convergent (terminating + confluent).

    Algorithm:
        1. Recursively normalize all children (bottom-up)
        2. Try to match each rule at the root
        3. If a rule matches, apply it and re-normalize the result
        4. Repeat until no rule matches (fixed point)

    Time complexity: O(n * r * d) per normalization step where
        n = term size, r = number of rules, d = max rewrite depth
    Space complexity: O(n) for the term tree

    Convergence: Guaranteed if the rule set is terminating and confluent.
    The formal proof of semantic preservation is in the Lean file.
    """
    def __init__(self):
        self.rules: List[RewriteRule] = []
        self.stats = {'rewrites': 0, 'normalize_calls': 0}

    def add_rule(self, rule: RewriteRule):
        self.rules.append(rule)

    def normalize(self, t: MSTerm) -> MSTerm:
        """Normalize a term to its canonical form.

        Returns:
            The normal form of t under the rule set.
            Satisfies: eval(A, ρ, normalize(t)) = eval(A, ρ, t)
            for every sound algebra A and assignment ρ.
        """
        self.stats['normalize_calls'] += 1

        # Step 1: Normalize all children
        if t.is_var():
            return t
        children = [self.normalize(c) for c in t.children]
        result = MSTerm(sort=t.sort, op=t.op, children=children)

        # Step 2: Apply rules at root until fixed point
        changed = True
        while changed:
            changed = False
            for rule in self.rules:
                match = self._try_match(rule, result)
                if match is not None:
                    result = match
                    self.stats['rewrites'] += 1
                    changed = True
                    break

        return result

    def _try_match(self, rule: RewriteRule, t: MSTerm) -> Optional[MSTerm]:
        """Try to apply a rule at the root of term t.

        Override this for pattern-matching rules. Default implementation
        handles the module rewrite rules directly.
        """
        return None  # Override in subclasses


class ModuleNormalizer(ManySortedNormalizer):
    """Normalizer for the two-sorted module theory.

    Implements four convergent rewrite rules:
      smul(0, v) → 0
      smul(1, v) → v
      smul(a, 0) → 0
      smul(a, v+w) → smul(a,v) + smul(a,w)
    """
    def _try_match(self, rule: RewriteRule, t: MSTerm) -> Optional[MSTerm]:
        if t.op is None or t.op.name != 'smul':
            return None

        a, v = t.children[0], t.children[1]

        # smul(0, v) → 0
        if a.op is not None and a.op.name == 'scZero':
            return MSTerm(sort='Vec', op=SortedOp('vZero', (), 'Vec'))

        # smul(1, v) → v
        if a.op is not None and a.op.name == 'scOne':
            return v

        # smul(a, 0) → 0
        if v.op is not None and v.op.name == 'vZero':
            return MSTerm(sort='Vec', op=SortedOp('vZero', (), 'Vec'))

        # smul(a, v+w) → smul(a,v) + smul(a,w)
        if v.op is not None and v.op.name == 'vAdd':
            v1, v2 = v.children[0], v.children[1]
            smul_op = SortedOp('smul', ('Scal', 'Vec'), 'Vec')
            vadd_op = SortedOp('vAdd', ('Vec', 'Vec'), 'Vec')
            left = self.normalize(MSTerm(sort='Vec', op=smul_op, children=[a, v1]))
            right = self.normalize(MSTerm(sort='Vec', op=smul_op, children=[a, v2]))
            return MSTerm(sort='Vec', op=vadd_op, children=[left, right])

        return None


# ─────────────────────────────────────────────────────────
# Algorithm 4: Many-Sorted Algebra (Evaluation)
# ─────────────────────────────────────────────────────────

class ManySortedAlgebra:
    """A many-sorted algebra: carriers and interpretations.

    Provides semantic evaluation of terms in a concrete model.

    Time complexity:
        eval: O(n) where n = term size
    Space complexity: O(d) stack depth where d = term depth
    """
    def __init__(self, carriers: Dict[Any, type],
                 interps: Dict[str, Callable],
                 var_assignment: Dict[str, Any]):
        self.carriers = carriers
        self.interps = interps
        self.var_assignment = var_assignment

    def eval(self, t: MSTerm) -> Any:
        """Evaluate a term in this algebra.

        The fundamental theorem guarantees:
            eval(normalize(t)) = eval(t)
        for any convergent sound rewrite system.
        """
        if t.is_var():
            return self.var_assignment[t.var_name]
        if t.op.name in self.interps:
            args = [self.eval(c) for c in t.children]
            return self.interps[t.op.name](*args)
        raise ValueError(f"No interpretation for {t.op.name}")


# ─────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Build module signature
    sig = ManySortedSignature(sorts={'Scal', 'Vec'})
    smul_op = SortedOp('smul', ('Scal', 'Vec'), 'Vec')
    vadd_op = SortedOp('vAdd', ('Vec', 'Vec'), 'Vec')
    sc_zero = SortedOp('scZero', (), 'Scal')
    sc_one = SortedOp('scOne', (), 'Scal')
    v_zero = SortedOp('vZero', (), 'Vec')
    for op in [smul_op, vadd_op, sc_zero, sc_one, v_zero]:
        sig.add_op(op)

    # Build a term: smul(1, vAdd(v0, smul(0, v1)))
    v0 = MSTerm(sort='Vec', var_name='v0')
    v1 = MSTerm(sort='Vec', var_name='v1')
    inner_smul = MSTerm(sort='Vec', op=smul_op,
                        children=[MSTerm(sort='Scal', op=sc_zero), v1])
    vadd = MSTerm(sort='Vec', op=vadd_op, children=[v0, inner_smul])
    term = MSTerm(sort='Vec', op=smul_op,
                  children=[MSTerm(sort='Scal', op=sc_one), vadd])

    print(f"Original term: {term}")
    print(f"Size: {term.size()}, Depth: {term.depth()}")

    # Normalize
    normalizer = ModuleNormalizer()
    normalizer.add_rule(RewriteRule("smul_zero", 'Vec', None, None))

    nf = normalizer.normalize(term)
    print(f"Normal form:   {nf}")
    print(f"Size: {nf.size()}, Depth: {nf.depth()}")
    print(f"Rewrites applied: {normalizer.stats['rewrites']}")

    # Evaluate in Z acting on Z²
    algebra = ManySortedAlgebra(
        carriers={'Scal': int, 'Vec': tuple},
        interps={
            'scZero': lambda: 0,
            'scOne': lambda: 1,
            'vZero': lambda: (0, 0),
            'vAdd': lambda v, w: (v[0]+w[0], v[1]+w[1]),
            'smul': lambda a, v: (a*v[0], a*v[1]),
        },
        var_assignment={'v0': (3, 1), 'v1': (-2, 5)}
    )

    val_orig = algebra.eval(term)
    val_nf = algebra.eval(nf)
    print(f"\nEvaluation in ℤ acting on ℤ²:")
    print(f"  Original: {val_orig}")
    print(f"  Normal:   {val_nf}")
    print(f"  Equal: {val_orig == val_nf} ✓" if val_orig == val_nf
          else f"  NOT Equal ✗")
