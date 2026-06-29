#!/usr/bin/env python3
"""
Algorithms for Operadic Architecture Minimization

Implements the key algorithms from the realization-minimality duality theorem:
1. Context equivalence computation
2. Quotient architecture construction
3. Minimality verification
4. Architecture isomorphism checking
"""

from dataclasses import dataclass, field
from typing import Any, Callable, Dict, FrozenSet, List, Optional, Set, Tuple
import itertools


@dataclass
class Signature:
    """Algebraic signature: operations with arities."""
    ops: Dict[str, int]  # op_name -> arity


@dataclass(frozen=True)
class Term:
    """Term in the free algebra."""
    kind: str  # 'gen' or 'app'
    label: str = ""
    children: Tuple['Term', ...] = ()

    def __repr__(self):
        if self.kind == 'gen':
            return self.label
        if not self.children:
            return f"{self.label}()"
        return f"{self.label}({', '.join(repr(c) for c in self.children)})"

    @staticmethod
    def gen(name: str) -> 'Term':
        return Term('gen', name)

    @staticmethod
    def app(op: str, args: List['Term']) -> 'Term':
        return Term('app', op, tuple(args))


@dataclass(frozen=True)
class Context:
    """One-hole context."""
    kind: str  # 'hole' or 'app'
    op: str = ""
    focus: int = 0
    others: Tuple[Term, ...] = ()
    sub: Optional['Context'] = None

    def plug(self, t: Term) -> Term:
        if self.kind == 'hole':
            return t
        args = list(self.others)
        args[self.focus] = self.sub.plug(t)
        return Term.app(self.op, args)

    @staticmethod
    def hole() -> 'Context':
        return Context('hole')

    @staticmethod
    def make(op: str, focus: int, others: List[Term],
             sub: 'Context') -> 'Context':
        return Context('app', op, focus, tuple(others), sub)


@dataclass
class Architecture:
    """Finite architecture with carrier, operations, generators, observations."""
    states: Set[int]
    ops: Dict[str, Callable]
    init: Dict[str, int]
    observe: Callable[[int], Any]

    def eval(self, t: Term) -> int:
        """Evaluate a term to a state."""
        if t.kind == 'gen':
            return self.init[t.label]
        args = [self.eval(c) for c in t.children]
        return self.ops[t.label](*args)

    def behavior(self, t: Term) -> Any:
        """Observable behavior of a term."""
        return self.observe(self.eval(t))


def enumerate_terms(sig: Signature, gens: List[str],
                    depth: int) -> List[Term]:
    """
    Enumerate all terms up to given depth.

    Time complexity: O(|Σ| × |G|^max_arity × depth)
    Space complexity: O(total_terms_generated)
    """
    current = [Term.gen(g) for g in gens]
    all_terms = list(current)

    for _ in range(depth):
        new = []
        for op, arity in sig.ops.items():
            for combo in itertools.product(current, repeat=arity):
                new.append(Term.app(op, list(combo)))
        all_terms.extend(new)
        current = new
        if not new:
            break
    return all_terms


def enumerate_contexts(sig: Signature, gens: List[str],
                       depth: int) -> List[Context]:
    """
    Enumerate contexts up to given depth.

    Time complexity: O(|Σ| × max_arity × |G|^(max_arity-1) × depth)
    """
    base = [Term.gen(g) for g in gens]
    ctxs = [Context.hole()]

    for _ in range(depth):
        new = []
        for op, arity in sig.ops.items():
            for focus in range(arity):
                for sub in ctxs:
                    other_slots = [base] * arity
                    for combo in itertools.product(*other_slots):
                        others = list(combo)
                        new.append(Context.make(op, focus, others, sub))
        ctxs.extend(new)
    return ctxs


def compute_context_signature(arch: Architecture, t: Term,
                               contexts: List[Context]) -> Tuple:
    """
    Compute the context signature of a term: its behavior in all contexts.

    This is the key data structure for context equivalence.
    Two terms are context-equivalent iff they have the same context signature.
    """
    return tuple(arch.behavior(c.plug(t)) for c in contexts)


def minimize_architecture(arch: Architecture, sig: Signature,
                           gens: List[str],
                           term_depth: int = 3,
                           ctx_depth: int = 2) -> Tuple[Architecture, Dict]:
    """
    Minimize an architecture via context equivalence quotient.

    Algorithm (Operadic Myhill-Nerode Minimization):
    1. Enumerate terms and contexts up to given depth
    2. Compute context signatures for all terms
    3. Partition terms by context signature (= equivalence classes)
    4. Build quotient architecture on equivalence classes
    5. Return minimal architecture and class mapping

    Time: O(|terms| × |contexts|) for signature computation
    Space: O(|terms| + |contexts|)

    Returns:
        (minimal_arch, class_map) where class_map : Term -> int
    """
    terms = enumerate_terms(sig, gens, term_depth)
    contexts = enumerate_contexts(sig, gens, ctx_depth)

    # Step 1: Compute context signatures
    signatures = {}
    for t in terms:
        signatures[t] = compute_context_signature(arch, t, contexts)

    # Step 2: Partition into equivalence classes
    sig_to_class = {}
    class_id = 0
    class_map = {}
    for t in terms:
        s = signatures[t]
        if s not in sig_to_class:
            sig_to_class[s] = class_id
            class_id += 1
        class_map[t] = sig_to_class[s]

    num_classes = class_id

    # Step 3: Find representatives
    reps = {}
    for t in terms:
        c = class_map[t]
        if c not in reps:
            reps[c] = t

    # Step 4: Build quotient operations
    q_ops = {}
    for op, arity in sig.ops.items():
        table = {}
        for combo in itertools.product(range(num_classes), repeat=arity):
            rep_args = [reps[c] for c in combo]
            result_term = Term.app(op, rep_args)
            result_state = arch.eval(result_term)
            # Find class of result
            result_sig = compute_context_signature(arch, result_term, contexts)
            if result_sig in sig_to_class:
                table[combo] = sig_to_class[result_sig]
            else:
                # Fallback: find by state matching
                for t2 in terms:
                    if arch.eval(t2) == result_state:
                        table[combo] = class_map[t2]
                        break
        if arity == 1:
            q_ops[op] = lambda x, tb=table: tb.get((x,), 0)
        elif arity == 2:
            q_ops[op] = lambda x, y, tb=table: tb.get((x, y), 0)
        else:
            q_ops[op] = lambda *args, tb=table: tb.get(tuple(args), 0)

    # Step 5: Build quotient architecture
    q_init = {g: class_map[Term.gen(g)] for g in gens}
    obs_table = {c: arch.observe(arch.eval(reps[c])) for c in range(num_classes)}
    q_observe = lambda s, ot=obs_table: ot.get(s)

    min_arch = Architecture(
        states=set(range(num_classes)),
        ops=q_ops,
        init=q_init,
        observe=q_observe
    )

    return min_arch, class_map


def verify_isomorphism(A: Architecture, B: Architecture,
                        sig: Signature, gens: List[str],
                        depth: int = 3) -> Optional[Dict[int, int]]:
    """
    Verify if two architectures are isomorphic by checking if
    they induce the same context equivalence classes.

    Returns the isomorphism mapping if found, None otherwise.
    """
    terms = enumerate_terms(sig, gens, depth)
    contexts = enumerate_contexts(sig, gens, depth)

    # Compute equivalence classes for both
    def get_classes(arch):
        sigs = {}
        for t in terms:
            sigs[t] = compute_context_signature(arch, t, contexts)
        sig_to_class = {}
        cid = 0
        cmap = {}
        for t in terms:
            s = sigs[t]
            if s not in sig_to_class:
                sig_to_class[s] = cid
                cid += 1
            cmap[t] = sig_to_class[s]
        return cmap, cid

    ca, na = get_classes(A)
    cb, nb = get_classes(B)

    if na != nb:
        return None

    # Build bijection: for each class in A, find corresponding class in B
    mapping = {}
    for t in terms:
        a_class = ca[t]
        b_class = cb[t]
        if a_class in mapping:
            if mapping[a_class] != b_class:
                return None
        else:
            mapping[a_class] = b_class

    # Check it's a bijection
    if len(set(mapping.values())) != na:
        return None

    return mapping


def compression_ratio(arch: Architecture, sig: Signature,
                       gens: List[str], depth: int = 3) -> float:
    """Compute the compression ratio: original states / minimal states."""
    min_arch, _ = minimize_architecture(arch, sig, gens, depth)
    return len(arch.states) / len(min_arch.states)


# ──────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────

if __name__ == '__main__':
    # Example: 6-state redundant architecture → 3-state minimal
    sig = Signature(ops={'f': 1})
    arch = Architecture(
        states={0, 1, 2, 3, 4, 5},
        ops={'f': lambda x: (x + 1) % 6},
        init={'a': 0, 'b': 3, 'c': 1},
        observe=lambda s: s % 3
    )

    min_arch, cmap = minimize_architecture(arch, sig, ['a', 'b', 'c'])
    print(f"Original: {len(arch.states)} states")
    print(f"Minimal:  {len(min_arch.states)} states")
    print(f"Ratio:    {compression_ratio(arch, sig, ['a', 'b', 'c']):.1f}×")

    # Verify uniqueness: build a second minimal architecture differently
    arch2 = Architecture(
        states={0, 1, 2, 3, 4, 5},
        ops={'f': lambda x: (x + 1) % 6},
        init={'a': 3, 'b': 0, 'c': 4},  # different assignment, same behavior
        observe=lambda s: s % 3
    )
    min2, _ = minimize_architecture(arch2, sig, ['a', 'b', 'c'])

    iso = verify_isomorphism(min_arch, min2, sig, ['a', 'b', 'c'])
    print(f"Isomorphic: {iso is not None}")
    if iso:
        print(f"Isomorphism: {iso}")
