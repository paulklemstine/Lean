#!/usr/bin/env python3
"""
Composable Theorem Transfer — Algorithms

Implements the core algorithms for certified theory morphism composition,
predicate transport, and bridge search.
"""

from dataclasses import dataclass, field
from typing import Callable, Optional, List, Dict, Tuple, Set
from collections import deque


# ═══════════════════════════════════════════════════════════════
# §1. Core Data Structures
# ═══════════════════════════════════════════════════════════════

@dataclass
class Theory:
    """A research theory with a named carrier and ℕ-valued invariant."""
    name: str
    invariant: Callable[[int], int]

    def inv(self, x: int) -> int:
        return self.invariant(x)

    def __hash__(self):
        return hash(self.name)

    def __eq__(self, other):
        return isinstance(other, Theory) and self.name == other.name


@dataclass
class Morphism:
    """A theory morphism: monotone map with certification."""
    source: Theory
    target: Theory
    to_fun: Callable[[int], int]
    label: str = ""

    def is_monotone(self, samples: range = range(100)) -> bool:
        """Verify monotonicity on sample inputs.

        Time complexity: O(|samples|)
        """
        return all(
            self.source.inv(x) <= self.target.inv(self.to_fun(x))
            for x in samples
        )


Predicate = Callable[[int], bool]


@dataclass
class CertifiedTransfer:
    """Bundled morphism + preservation witness.

    Attributes:
        morphism: The underlying theory morphism
        source_pred: Source predicate P
        target_pred: Target predicate Q
        verified: Whether preservation has been empirically verified
    """
    morphism: Morphism
    source_pred: Predicate
    target_pred: Predicate
    verified: bool = False

    def verify(self, samples: range = range(100)) -> bool:
        """Verify preservation on samples.

        Time complexity: O(|samples|)
        """
        self.verified = all(
            (not self.source_pred(x)) or
            self.target_pred(self.morphism.to_fun(x))
            for x in samples
        )
        return self.verified

    def apply(self, x: int) -> Tuple[int, bool]:
        """Apply the transfer to a concrete element.

        Returns: (image, target_pred_holds)
        Time complexity: O(1) per application
        """
        y = self.morphism.to_fun(x)
        return y, self.target_pred(y)


# ═══════════════════════════════════════════════════════════════
# §2. Composition Algorithm
# ═══════════════════════════════════════════════════════════════

def compose_morphisms(phi: Morphism, psi: Morphism) -> Morphism:
    """Compose two theory morphisms.

    Algorithm: ComposeTheoryHom
    Input: φ : T₁ → T₂, ψ : T₂ → T₃
    Output: φ;ψ : T₁ → T₃

    Time complexity: O(1) for construction
    Space complexity: O(1) (closure over phi, psi)

    The composed morphism's to_fun is ψ.to_fun ∘ φ.to_fun.
    Monotonicity follows from transitivity of ≤.
    """
    if phi.target != psi.source:
        raise ValueError(
            f"Cannot compose: {phi.target.name} ≠ {psi.source.name}"
        )
    return Morphism(
        source=phi.source,
        target=psi.target,
        to_fun=lambda x, _phi=phi, _psi=psi: _psi.to_fun(_phi.to_fun(x)),
        label=f"({phi.label} ; {psi.label})"
    )


def compose_transfers(
    ct1: CertifiedTransfer,
    ct2: CertifiedTransfer
) -> CertifiedTransfer:
    """Compose two certified transfers.

    Algorithm: ComposeCertifiedTransfer
    Input: ct₁ : (T₁, P) → (T₂, Q), ct₂ : (T₂, Q) → (T₃, R)
    Output: ct₁;ct₂ : (T₁, P) → (T₃, R)

    Time complexity: O(1) for construction
    Preservation proof: By ct₁, P(x) → Q(φ(x)).
                        By ct₂, Q(φ(x)) → R(ψ(φ(x))).
                        Therefore P(x) → R((φ;ψ)(x)).
    """
    composed_morph = compose_morphisms(ct1.morphism, ct2.morphism)
    return CertifiedTransfer(
        morphism=composed_morph,
        source_pred=ct1.source_pred,
        target_pred=ct2.target_pred,
        verified=ct1.verified and ct2.verified
    )


def compose_chain(transfers: List[CertifiedTransfer]) -> CertifiedTransfer:
    """Compose an arbitrary chain of certified transfers.

    Algorithm: ComposeChain
    Input: [ct₁, ct₂, ..., ctₖ] compatible certified transfers
    Output: ct₁ ; ct₂ ; ... ; ctₖ

    Time complexity: O(k) for construction
    """
    if not transfers:
        raise ValueError("Empty chain")
    result = transfers[0]
    for ct in transfers[1:]:
        result = compose_transfers(result, ct)
    return result


# ═══════════════════════════════════════════════════════════════
# §3. Bridge Search Algorithm
# ═══════════════════════════════════════════════════════════════

@dataclass
class TheoryGraph:
    """A graph of theories connected by morphisms.

    Nodes: theories
    Edges: morphisms (directed)
    """
    theories: Dict[str, Theory] = field(default_factory=dict)
    morphisms: List[Morphism] = field(default_factory=list)
    adjacency: Dict[str, List[Morphism]] = field(default_factory=dict)

    def add_theory(self, theory: Theory) -> None:
        """Register a theory in the graph."""
        self.theories[theory.name] = theory
        if theory.name not in self.adjacency:
            self.adjacency[theory.name] = []

    def add_morphism(self, morph: Morphism) -> None:
        """Register a morphism in the graph."""
        self.add_theory(morph.source)
        self.add_theory(morph.target)
        self.morphisms.append(morph)
        self.adjacency[morph.source.name].append(morph)

    def find_path(self, source_name: str, target_name: str) -> Optional[List[Morphism]]:
        """Find a path of morphisms from source to target using BFS.

        Algorithm: BridgeSearch
        Input: source theory name, target theory name
        Output: list of morphisms forming a path, or None

        Time complexity: O(|V| + |E|) where V = theories, E = morphisms
        Space complexity: O(|V|) for the BFS queue
        """
        if source_name not in self.theories or target_name not in self.theories:
            return None
        if source_name == target_name:
            return []

        visited: Set[str] = {source_name}
        # Queue entries: (current_theory_name, path_of_morphisms)
        queue: deque = deque([(source_name, [])])

        while queue:
            current, path = queue.popleft()
            for morph in self.adjacency.get(current, []):
                next_name = morph.target.name
                new_path = path + [morph]
                if next_name == target_name:
                    return new_path
                if next_name not in visited:
                    visited.add(next_name)
                    queue.append((next_name, new_path))

        return None

    def compose_path(self, path: List[Morphism]) -> Optional[Morphism]:
        """Compose a path of morphisms into a single morphism.

        Time complexity: O(k) where k = len(path)
        """
        if not path:
            return None
        result = path[0]
        for morph in path[1:]:
            result = compose_morphisms(result, morph)
        return result

    def transfer(self, source_name: str, target_name: str,
                 source_pred: Predicate) -> Optional[CertifiedTransfer]:
        """Find and compose a certified transfer from source to target.

        Algorithm: AutoTransfer
        Input: source theory, target theory, source predicate
        Output: CertifiedTransfer or None

        Time complexity: O(|V| + |E|) for path search + O(k) for composition
        """
        path = self.find_path(source_name, target_name)
        if path is None:
            return None
        composed = self.compose_path(path)
        if composed is None:
            return None
        # Pushforward predicate
        target_pred: Predicate = lambda y, _c=composed, _p=source_pred: any(
            _p(x) and _c.to_fun(x) == y for x in range(100)
        )
        return CertifiedTransfer(
            morphism=composed,
            source_pred=source_pred,
            target_pred=target_pred
        )


# ═══════════════════════════════════════════════════════════════
# §4. Depth Certificate Transport
# ═══════════════════════════════════════════════════════════════

def depth_predicate(theory: Theory, n: int) -> Predicate:
    """Create a depth-at-least-n predicate for a theory.

    HasDepthAtLeast T n x ≡ n ≤ T.Inv(x)
    """
    return lambda x, _t=theory, _n=n: _n <= _t.inv(x)


def verify_depth_transfer(
    morph: Morphism,
    n: int,
    samples: range = range(50)
) -> bool:
    """Verify that a morphism preserves depth-n certificates.

    By the monotonicity of theory morphisms, this always holds:
    n ≤ T₁.Inv(x) ≤ T₂.Inv(φ(x))
    """
    P = depth_predicate(morph.source, n)
    Q = depth_predicate(morph.target, n)
    return all((not P(x)) or Q(morph.to_fun(x)) for x in samples)


# ═══════════════════════════════════════════════════════════════
# §5. Example Usage
# ═══════════════════════════════════════════════════════════════

def main():
    """Demonstrate the algorithms with the catalog theories."""
    # Build theories
    height = Theory("Height", lambda n: n)
    cell = Theory("Cell", lambda n: n * (n + 1))
    dim = Theory("Dimension", lambda n: n + 1)
    stab = Theory("Stability", lambda n: n)
    cap = Theory("Capacity", lambda n: n)

    # Build morphisms
    h2c = Morphism(height, cell, lambda x: x, "h→cell")
    h2d = Morphism(height, dim, lambda x: x, "h→dim")
    d2s = Morphism(dim, stab, lambda x: x + 1, "dim→stab")
    s2c_cap = Morphism(stab, cap, lambda x: x, "stab→cap")

    # Build graph
    graph = TheoryGraph()
    for m in [h2c, h2d, d2s, s2c_cap]:
        graph.add_morphism(m)

    print("Theory Graph:")
    print(f"  Theories: {list(graph.theories.keys())}")
    print(f"  Morphisms: {[m.label for m in graph.morphisms]}")

    # Find path from Height to Capacity
    path = graph.find_path("Height", "Capacity")
    if path:
        print(f"\n  Path Height → Capacity: {[m.label for m in path]}")
        composed = graph.compose_path(path)
        print(f"  Composed morphism: {composed.label}")
        print(f"  Monotone: {composed.is_monotone()}")

        # Verify depth transfer
        for n in [1, 2, 3, 5]:
            ok = verify_depth_transfer(composed, n)
            print(f"  Depth-{n} transfer: {'✓' if ok else '✗'}")

    # Auto-transfer with predicate
    print("\nAuto-transfer: Height → Capacity with ArithSig predicate:")
    ct = graph.transfer("Height", "Capacity", lambda x: x >= 2)
    if ct:
        for x in range(6):
            y, q = ct.apply(x)
            print(f"  x={x}: image={y}, target_pred={q}")

    # Chain composition
    print("\nChain composition test:")
    ct1 = CertifiedTransfer(h2d, lambda x: x >= 2, lambda x: dim.inv(x) >= 2)
    ct2 = CertifiedTransfer(d2s, lambda x: dim.inv(x) >= 2, lambda x: x >= 2)
    ct3 = CertifiedTransfer(s2c_cap, lambda x: x >= 2, lambda x: x >= 2)

    chain = compose_chain([ct1, ct2, ct3])
    ct1.verify(); ct2.verify(); ct3.verify(); chain.verify()
    print(f"  ct1 verified: {ct1.verified}")
    print(f"  ct2 verified: {ct2.verified}")
    print(f"  ct3 verified: {ct3.verified}")
    print(f"  chain verified: {chain.verified}")
    print(f"  chain label: {chain.morphism.label}")


if __name__ == "__main__":
    main()
