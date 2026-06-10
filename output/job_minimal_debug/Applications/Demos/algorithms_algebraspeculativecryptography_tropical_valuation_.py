#!/usr/bin/env python3
"""
Algorithms for Tropical Valuation Observer Duality

Implements the core algorithms from the research paper:
1. Leakage Classification — partition configurations by valuation signatures
2. Minimal Realization — construct the canonical minimal leakage model
3. Observer Comparison — check if one observer family refines another
4. Separation Witness — find the observer that separates two configurations
"""

from collections import defaultdict
from typing import Dict, List, Tuple, Callable, Optional, Set


class ObserverFamily:
    """A finite family of observers from configurations into a semiring."""

    def __init__(self, observers: Dict[str, Callable]):
        self.observers = observers
        self.indices = sorted(observers.keys())

    def observe(self, index: str, config) -> float:
        return self.observers[index](config)

    def signature(self, config, valuation: Callable) -> Tuple:
        """Compute valuation signature of a configuration."""
        return tuple(valuation(self.observe(i, config)) for i in self.indices)


class LeakageClassification:
    """Result of classifying configurations by observational indistinguishability."""

    def __init__(self, classes: Dict[Tuple, List], signatures: Dict, configs: List):
        self.classes = classes
        self.signatures = signatures
        self.configs = configs

    @property
    def num_classes(self) -> int:
        return len(self.classes)

    @property
    def compression_ratio(self) -> float:
        return len(self.configs) / self.num_classes if self.num_classes > 0 else float('inf')

    def are_indistinguishable(self, c1, c2) -> bool:
        return self.signatures[c1] == self.signatures[c2]

    def get_class(self, config) -> List:
        sig = self.signatures[config]
        return self.classes[sig]


class MinimalRealization:
    """A minimal realization of a leakage model."""

    def __init__(self, states: List[Tuple], encode_map: Dict, observe_fn: Callable,
                 observer_indices: List[str]):
        self.states = states
        self.encode_map = encode_map
        self.observe_fn = observe_fn
        self.observer_indices = observer_indices

    def encode(self, config):
        return self.encode_map[config]

    def observe(self, index: str, state: Tuple):
        idx = self.observer_indices.index(index)
        return state[idx]

    @property
    def num_states(self) -> int:
        return len(self.states)


def classify_leakage(configs: List, O: ObserverFamily,
                     v: Callable) -> LeakageClassification:
    """
    Classify configurations into observational indistinguishability classes.

    Algorithm: Compute valuation signature for each configuration,
    group by signature equality.

    Complexity: O(|C| * |ι|) time and space.

    Args:
        configs: List of configurations
        O: Observer family
        v: Valuation morphism (semiring homomorphism)

    Returns:
        LeakageClassification with classes indexed by signatures
    """
    classes: Dict[Tuple, List] = defaultdict(list)
    signatures: Dict = {}

    for c in configs:
        sig = O.signature(c, v)
        classes[sig].append(c)
        signatures[c] = sig

    return LeakageClassification(dict(classes), signatures, configs)


def build_minimal_realization(classification: LeakageClassification,
                              O: ObserverFamily) -> MinimalRealization:
    """
    Construct the canonical minimal realization from a leakage classification.

    The states are the distinct signatures, encoding maps each config to
    its signature, and observation is coordinate projection.

    Complexity: O(|C| * |ι|) time.

    Args:
        classification: Pre-computed leakage classification
        O: Observer family (for index names)

    Returns:
        MinimalRealization with |classes| states
    """
    states = sorted(classification.classes.keys())
    encode_map = classification.signatures.copy()

    def observe_fn(index: str, state: Tuple):
        idx = O.indices.index(index)
        return state[idx]

    return MinimalRealization(states, encode_map, observe_fn, O.indices)


def verify_soundness(realization: MinimalRealization, configs: List,
                     O: ObserverFamily, v: Callable) -> bool:
    """
    Verify that a realization is sound: observe(i, encode(c)) = v(O_i(c)).

    Complexity: O(|C| * |ι|).
    """
    for c in configs:
        state = realization.encode(c)
        for idx in O.indices:
            observed = realization.observe(idx, state)
            expected = v(O.observe(idx, c))
            if observed != expected:
                return False
    return True


def verify_minimality(realization: MinimalRealization, configs: List,
                      classification: LeakageClassification) -> bool:
    """
    Verify minimality: encode(c1) = encode(c2) iff c1 ~ c2.

    Complexity: O(|C|^2).
    """
    for i, c1 in enumerate(configs):
        for c2 in configs[i+1:]:
            same_state = (realization.encode(c1) == realization.encode(c2))
            indist = classification.are_indistinguishable(c1, c2)
            if same_state != indist:
                return False
    return True


def find_separation_witness(c1, c2, O: ObserverFamily,
                            v: Callable) -> Optional[str]:
    """
    Find an observer that separates two distinguishable configurations.

    Returns None if configurations are indistinguishable.

    Complexity: O(|ι|).
    """
    for idx in O.indices:
        if v(O.observe(idx, c1)) != v(O.observe(idx, c2)):
            return idx
    return None


def is_refinement(configs: List, O1: ObserverFamily, O2: ObserverFamily,
                  v: Callable) -> bool:
    """
    Check if O2 refines O1: every O1-class is a union of O2-classes.

    Complexity: O(|C| * (|ι1| + |ι2|)).
    """
    class1 = classify_leakage(configs, O1, v)
    class2 = classify_leakage(configs, O2, v)

    for members in class2.classes.values():
        sigs1 = set(class1.signatures[c] for c in members)
        if len(sigs1) > 1:
            return False
    return True


def product_observer_family(O1: ObserverFamily,
                            O2: ObserverFamily) -> ObserverFamily:
    """
    Form the product of two observer families.

    The product observes through both families simultaneously.
    """
    combined = {}
    for idx, fn in O1.observers.items():
        combined[f"L_{idx}"] = fn
    for idx, fn in O2.observers.items():
        combined[f"R_{idx}"] = fn
    return ObserverFamily(combined)


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    # Example: 8 configurations, 3 observers
    configs = list(range(8))
    O = ObserverFamily({
        'parity': lambda c: c % 2,
        'mod3': lambda c: c % 3,
        'high_bit': lambda c: c >> 2,
    })
    v = lambda x: x  # identity valuation

    # Classify
    classification = classify_leakage(configs, O, v)
    print(f"Configurations: {configs}")
    print(f"Classes: {classification.num_classes}")
    print(f"Compression ratio: {classification.compression_ratio:.2f}")

    for sig, members in sorted(classification.classes.items()):
        print(f"  Signature {sig}: {members}")

    # Build minimal realization
    realization = build_minimal_realization(classification, O)
    print(f"\nMinimal realization: {realization.num_states} states")

    # Verify
    print(f"Sound: {verify_soundness(realization, configs, O, v)}")
    print(f"Minimal: {verify_minimality(realization, configs, classification)}")

    # Separation witness
    w = find_separation_witness(0, 1, O, v)
    print(f"\nSeparation witness for 0 vs 1: observer '{w}'")
