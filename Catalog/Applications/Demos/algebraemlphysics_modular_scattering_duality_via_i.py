#!/usr/bin/env python3
"""
Applications of Closure-Scattering Duality Theory.

Demonstrates real-world applications of the minimal resonance realization framework:
1. Automata minimization (Myhill-Nerode analogue)
2. Signal processing: system identification from I/O data
3. Network flow analysis: channel capacity reduction
4. Tropical/max-plus system identification
"""

import math
from algorithms import (
    ClosureScatteringSystem,
    compute_response_profile,
    compute_resonance_classes,
    construct_minimal_realization,
    find_isomorphism,
    is_separated,
    analyze_spectral_boundary,
    compute_closure_defect,
)
from typing import FrozenSet


def application_automata_minimization():
    """Application 1: Deterministic Finite Automaton Minimization.

    The resonance congruence specializes to Myhill-Nerode equivalence
    when the system is a DFA. This demonstrates that our framework
    generalizes classical automata minimization.
    """
    print("=" * 70)
    print("APPLICATION 1: Automata Minimization via Resonance Congruence")
    print("=" * 70)
    print()

    # A DFA recognizing strings ending in "ab" over {a, b}
    # States: 0=start, 1=saw 'a', 2=saw 'ab' (accept), 3=dead (redundant copy of 0)
    # We encode this as a closure-scattering system:
    # - Transfer encodes one input symbol (say 'a')
    # - Boundary records acceptance status

    # For simplicity: transfer = transition on 'a', boundary[c=0] = accept status,
    # boundary[c=1] = transition on 'b' then accept status
    states = 4
    channels = 2

    # Transitions: on 'a': 0->1, 1->1, 2->0, 3->1
    transfer_a = lambda x: [1, 1, 0, 1][x]

    # Boundary: channel 0 = is accepting? channel 1 = is accepting after 'b'?
    def boundary(x, c):
        if c == 0:
            return 1.0 if x == 2 else 0.0
        else:
            # After reading 'b': 0->0, 1->2, 2->0, 3->0
            after_b = [0, 2, 0, 0][x]
            return 1.0 if after_b == 2 else 0.0

    S = ClosureScatteringSystem(states, channels, transfer_a, boundary)

    print(f"DFA with {states} states (state 3 is redundant copy of state 0)")
    print(f"Separated: {is_separated(S)}")

    classes = compute_resonance_classes(S)
    print(f"Myhill-Nerode classes: {len(classes)}")
    for p, equiv_states in classes.items():
        print(f"  States {equiv_states} are equivalent")

    M, qmap = construct_minimal_realization(S)
    print(f"Minimized DFA: {M.n_states} states (from {S.n_states})")
    print()


def application_signal_processing():
    """Application 2: System Identification from Input-Output Data.

    Given a "black box" linear system observed through boundary channels,
    reconstruct the minimal internal model. This is the Hankel realization
    analogue in our framework.
    """
    print("=" * 70)
    print("APPLICATION 2: System Identification from Boundary Data")
    print("=" * 70)
    print()

    # A discrete-time system with hidden internal dynamics
    # States represent internal modes; boundary observations are
    # the externally measurable quantities.

    # "True" system with 5 internal modes, but only 3 are distinguishable
    n_modes = 5
    n_sensors = 3

    # Transfer: internal dynamics (permutation with redundancy)
    transfer = lambda x: [1, 2, 0, 4, 3][x]

    # Boundary: sensor readings
    sensor_values = {
        (0, 0): 1.0, (0, 1): 0.0, (0, 2): 0.5,
        (1, 0): 0.0, (1, 1): 1.0, (1, 2): 0.3,
        (2, 0): 0.5, (2, 1): 0.5, (2, 2): 1.0,
        (3, 0): 0.0, (3, 1): 1.0, (3, 2): 0.3,  # same as mode 1
        (4, 0): 1.0, (4, 1): 0.0, (4, 2): 0.5,  # same as mode 0
    }
    boundary = lambda x, c: sensor_values[(x, c)]

    S = ClosureScatteringSystem(n_modes, n_sensors, transfer, boundary)

    # Check: modes 0≡4 and 1≡3 should be identified
    classes = compute_resonance_classes(S)
    print(f"Physical system: {n_modes} internal modes, {n_sensors} sensors")
    print(f"Observable modes: {len(classes)}")
    for p, modes in classes.items():
        if len(modes) > 1:
            print(f"  Modes {modes} are observationally identical → same resonance class")
        else:
            print(f"  Mode {modes[0]} is uniquely observable")

    M, qmap = construct_minimal_realization(S)
    print(f"\nMinimal model: {M.n_states} effective modes")
    print("This is the smallest model reproducing all sensor data.")
    print()

    # Verify: the minimal realization preserves all observations
    spectral = analyze_spectral_boundary(S)
    spectral_min = analyze_spectral_boundary(M)
    print(f"Observation profiles match: "
          f"{set(spectral['profiles'].values()) == set(spectral_min['profiles'].values())}")
    print()


def application_network_analysis():
    """Application 3: Network Flow Analysis with Closure Structure.

    Nodes in a network have closure structure (reachability / influence spread).
    Transfer models packet forwarding. Boundary observations are edge measurements.
    Resonance identifies nodes with indistinguishable network behavior.
    """
    print("=" * 70)
    print("APPLICATION 3: Network Flow Reduction via Resonance")
    print("=" * 70)
    print()

    # 8-node network with symmetry
    n_nodes = 8
    n_ports = 2

    # Transfer: routing (packet forwarding to next hop)
    routing = lambda x: [1, 2, 3, 0, 5, 6, 7, 4][x]

    # Boundary: port measurements (symmetric pairs have same measurements)
    def boundary(node, port):
        if port == 0:
            return math.sin(node * math.pi / 4)
        else:
            return math.cos(node * math.pi / 4)

    # Closure: reachability (add direct neighbors)
    adjacency = {
        0: {1, 7}, 1: {0, 2}, 2: {1, 3}, 3: {2, 4},
        4: {3, 5}, 5: {4, 6}, 6: {5, 7}, 7: {6, 0}
    }

    def closure(A: FrozenSet) -> FrozenSet:
        result = set(A)
        for x in A:
            result |= adjacency.get(x, set())
        return frozenset(result)

    S = ClosureScatteringSystem(n_nodes, n_ports, routing, boundary, closure)

    print(f"Network: {n_nodes} nodes, ring topology")
    classes = compute_resonance_classes(S, depth=n_nodes + 2)
    print(f"Behaviorally distinct nodes: {len(classes)}")
    for p, nodes in classes.items():
        print(f"  Nodes {nodes}: same forwarding behavior")

    # Check closure defects
    print("\nClosure defect analysis (resonance detection):")
    for subset in [{0}, {0, 4}, {0, 2, 4, 6}]:
        defect = compute_closure_defect(S, frozenset(subset))
        status = "RESONANCE" if defect else "compatible"
        print(f"  A={subset}: defect = {set(defect)} → {status}")

    M, qmap = construct_minimal_realization(S, depth=n_nodes + 2)
    print(f"\nReduced network model: {M.n_states} effective nodes (from {n_nodes})")
    print()


def application_tropical_system():
    """Application 4: Tropical (Max-Plus) System Identification.

    In the max-plus semiring (R ∪ {-∞}, max, +), closure-scattering systems
    model discrete event systems and scheduling networks.
    Resonance congruence identifies states with identical worst-case timing.
    """
    print("=" * 70)
    print("APPLICATION 4: Tropical System Identification")
    print("=" * 70)
    print()

    # Max-plus system: states are processing stages
    # Transfer: advance to next stage with timing
    # Boundary: observable processing times through channels

    n_stages = 6
    n_outputs = 2

    # Processing times (used as boundary observations)
    # Stages 0,3 have same timing; 1,4 have same timing; 2,5 have same timing
    timing = {
        (0, 0): 3.0, (0, 1): 1.0,
        (1, 0): 2.0, (1, 1): 4.0,
        (2, 0): 5.0, (2, 1): 2.0,
        (3, 0): 3.0, (3, 1): 1.0,  # = stage 0
        (4, 0): 2.0, (4, 1): 4.0,  # = stage 1
        (5, 0): 5.0, (5, 1): 2.0,  # = stage 2
    }

    # Transfer: pipeline advancement (with redundant parallel path)
    transfer = lambda x: [1, 2, 0, 4, 5, 3][x]

    # In max-plus, boundary observation is the processing time
    boundary = lambda x, c: timing[(x, c)]

    S = ClosureScatteringSystem(n_stages, n_outputs, transfer, boundary)

    print(f"Tropical processing system: {n_stages} stages, {n_outputs} output ports")
    print(f"Separated: {is_separated(S)}")

    classes = compute_resonance_classes(S)
    print(f"Distinct timing profiles: {len(classes)}")
    for p, stages in classes.items():
        print(f"  Stages {stages}: identical processing behavior")

    M, qmap = construct_minimal_realization(S)
    print(f"\nMinimal tropical model: {M.n_states} effective stages")
    print(f"State reduction: {S.n_states} → {M.n_states} "
          f"({(1 - M.n_states/S.n_states)*100:.0f}% reduction)")

    print("\nTiming profiles of minimal model:")
    for i in range(M.n_states):
        p = compute_response_profile(M, i, depth=4)
        print(f"  Stage {i}: {[list(row) for row in p[:3]]}...")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Closure-Scattering Duality Theory                ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    application_automata_minimization()
    application_signal_processing()
    application_network_analysis()
    application_tropical_system()

    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Demonstration of Closure-Scattering Systems and Minimal Resonance Realization.

This script provides concrete numerical examples of the theorems proved in the
ModularScatteringDuality module, illustrating how closure-scattering systems
can be reconstructed from boundary response data.
"""

import numpy as np
from itertools import product


class ClosureScatteringSystem:
    """A finite closure-scattering system over the max-plus semiring.

    States are integers 0..n-1, channels are integers 0..m-1.
    The 'semiring' is taken as ordinary reals for demonstration.
    """

    def __init__(self, n_states, n_channels, transfer, boundary, closure=None):
        """
        Args:
            n_states: number of states
            n_channels: number of channels
            transfer: function int -> int (state evolution)
            boundary: function (int, int) -> float (boundary observation)
            closure: function frozenset -> frozenset (closure operator on subsets)
        """
        self.n_states = n_states
        self.n_channels = n_channels
        self.transfer = transfer
        self.boundary = boundary
        if closure is None:
            # Default: identity closure
            self.closure = lambda A: A
        else:
            self.closure = closure

    def response_profile(self, x, depth=10):
        """Compute the response profile of state x up to given depth.

        Returns a list of lists: profile[n][c] = boundary(T^n(x), c)
        """
        profile = []
        state = x
        for n in range(depth):
            row = [self.boundary(state, c) for c in range(self.n_channels)]
            profile.append(tuple(row))
            state = self.transfer(state)
        return tuple(profile)

    def all_response_profiles(self, depth=10):
        """Compute response profiles for all states."""
        return {x: self.response_profile(x, depth) for x in range(self.n_states)}

    def resonance_classes(self, depth=10):
        """Compute resonance equivalence classes."""
        profiles = self.all_response_profiles(depth)
        classes = {}
        for x, p in profiles.items():
            if p not in classes:
                classes[p] = []
            classes[p].append(x)
        return classes

    def is_separated(self, depth=10):
        """Check if the system is separated (all profiles distinct)."""
        profiles = self.all_response_profiles(depth)
        return len(set(profiles.values())) == self.n_states

    def closure_defect(self, A):
        """Compute the closure defect of a set A."""
        cl_A = self.closure(A)
        T_cl_A = frozenset(self.transfer(x) for x in cl_A)
        T_A = frozenset(self.transfer(x) for x in A)
        cl_T_A = self.closure(T_A)
        return T_cl_A - cl_T_A

    def minimal_realization(self, depth=10):
        """Construct the minimal realization by quotienting by resonance equivalence.

        Returns a new ClosureScatteringSystem on the quotient states.
        """
        classes = self.resonance_classes(depth)
        profiles = list(classes.keys())
        n_new = len(profiles)
        profile_to_idx = {p: i for i, p in enumerate(profiles)}

        # Transfer on quotient: shift the profile
        def new_transfer(i):
            p = profiles[i]
            shifted = p[1:] + (p[-1],)  # approximate shift for finite depth
            # Find the closest matching profile
            for j, q in enumerate(profiles):
                if q[:-1] == shifted[:-1]:  # match on all but last
                    return j
            return i  # fallback

        # Actually, use the original transfer to define the new one
        # For each profile class, pick a representative and transfer it
        reps = {p: classes[p][0] for p in profiles}

        def new_transfer_exact(i):
            p = profiles[i]
            rep = reps[p]
            new_rep = self.transfer(rep)
            new_profile = self.response_profile(new_rep, depth)
            return profile_to_idx.get(new_profile, i)

        # Boundary on quotient: read from profile at n=0
        def new_boundary(i, c):
            return profiles[i][0][c]

        return ClosureScatteringSystem(
            n_states=n_new,
            n_channels=self.n_channels,
            transfer=new_transfer_exact,
            boundary=new_boundary
        )


def demo_basic_system():
    """Demo 1: A simple system with 4 states and 2 channels."""
    print("=" * 70)
    print("DEMO 1: Basic Closure-Scattering System")
    print("=" * 70)
    print()

    # 4 states, 2 channels
    # Transfer: cyclic permutation 0->1->2->3->0
    transfer = lambda x: (x + 1) % 4

    # Boundary: different observations per state/channel
    boundary_values = {
        (0, 0): 1.0, (0, 1): 0.0,
        (1, 0): 0.5, (1, 1): 1.0,
        (2, 0): 0.0, (2, 1): 0.5,
        (3, 0): 1.0, (3, 1): 0.5,
    }
    boundary = lambda x, c: boundary_values[(x, c)]

    S = ClosureScatteringSystem(4, 2, transfer, boundary)

    print("System: 4 states, 2 channels, cyclic transfer T(x) = (x+1) mod 4")
    print()

    # Show response profiles
    print("Response profiles (depth 6):")
    profiles = S.all_response_profiles(6)
    for x in range(4):
        print(f"  State {x}: {profiles[x][:4]}...")

    print()
    print(f"Separated: {S.is_separated(6)}")

    classes = S.resonance_classes(6)
    print(f"Number of resonance classes: {len(classes)}")
    for p, states in classes.items():
        print(f"  Class with states {states}: profile starts {p[:2]}...")

    print()


def demo_redundant_system():
    """Demo 2: A system with redundant states that get identified."""
    print("=" * 70)
    print("DEMO 2: Redundant System → Minimal Realization")
    print("=" * 70)
    print()

    # 6 states, 2 channels
    # States 0,3 are "copies", states 1,4 are "copies", states 2,5 are "copies"
    transfer = lambda x: [1, 2, 0, 4, 5, 3][x]

    boundary_values = {
        (0, 0): 1.0, (0, 1): 0.0,
        (1, 0): 0.0, (1, 1): 1.0,
        (2, 0): 0.5, (2, 1): 0.5,
        (3, 0): 1.0, (3, 1): 0.0,  # same as state 0
        (4, 0): 0.0, (4, 1): 1.0,  # same as state 1
        (5, 0): 0.5, (5, 1): 0.5,  # same as state 2
    }
    boundary = lambda x, c: boundary_values[(x, c)]

    S = ClosureScatteringSystem(6, 2, transfer, boundary)

    print("System: 6 states, 2 channels")
    print("States 0≡3, 1≡4, 2≡5 have identical boundary values and parallel transfer")
    print()

    print(f"Separated: {S.is_separated()}")

    classes = S.resonance_classes()
    print(f"Resonance equivalence classes: {len(classes)}")
    for p, states in classes.items():
        print(f"  States {states} are equivalent")

    print()
    print("Constructing minimal realization...")
    M = S.minimal_realization()
    print(f"Minimal realization has {M.n_states} states (reduced from {S.n_states})")
    print(f"Minimal realization separated: {M.is_separated()}")
    print()

    # Verify response profiles match
    orig_profiles = set(S.all_response_profiles().values())
    min_profiles = set(M.all_response_profiles().values())
    print(f"Original distinct profiles: {len(orig_profiles)}")
    print(f"Minimal realization profiles: {len(min_profiles)}")
    print(f"Profile sets match: {orig_profiles == min_profiles}")
    print()


def demo_closure_defect():
    """Demo 3: Closure defect as resonance."""
    print("=" * 70)
    print("DEMO 3: Closure Defect = Resonance")
    print("=" * 70)
    print()

    # 4 states, closure that adds neighbors
    def closure(A):
        result = set(A)
        for x in A:
            if x > 0:
                result.add(x - 1)
            if x < 3:
                result.add(x + 1)
        return frozenset(result)

    transfer = lambda x: (x + 1) % 4
    boundary = lambda x, c: float(x == c)

    S = ClosureScatteringSystem(4, 4, transfer, boundary, closure)

    print("System: 4 states in a line, closure adds adjacent states")
    print("Transfer: cyclic shift T(x) = (x+1) mod 4")
    print()

    for subset_tuple in [(0,), (1,), (0, 1), (0, 2)]:
        A = frozenset(subset_tuple)
        defect = S.closure_defect(A)
        cl_A = closure(A)
        T_A = frozenset(transfer(x) for x in A)
        cl_T_A = closure(T_A)
        T_cl_A = frozenset(transfer(x) for x in cl_A)

        print(f"  A = {set(A)}")
        print(f"    cl(A) = {set(cl_A)}")
        print(f"    T(cl(A)) = {set(T_cl_A)}")
        print(f"    cl(T(A)) = {set(cl_T_A)}")
        print(f"    Defect T(cl(A))\\cl(T(A)) = {set(defect)}")
        print(f"    → {'No resonance' if not defect else 'RESONANCE DETECTED'}")
        print()


def demo_uniqueness():
    """Demo 4: Two separated systems with same profiles → isomorphic."""
    print("=" * 70)
    print("DEMO 4: Uniqueness of Separated Realizations")
    print("=" * 70)
    print()

    # System 1: states {0,1,2}, transfer 0->1->2->0
    transfer1 = lambda x: (x + 1) % 3
    boundary1 = lambda x, c: [[1.0, 0.0], [0.0, 1.0], [0.5, 0.5]][x][c]
    S1 = ClosureScatteringSystem(3, 2, transfer1, boundary1)

    # System 2: states {0,1,2} but relabeled: state mapping 0↔2
    transfer2 = lambda x: [1, 2, 0][x]  # 2->1->0->2 (relabeled)
    boundary2 = lambda x, c: [[0.5, 0.5], [0.0, 1.0], [1.0, 0.0]][x][c]
    S2 = ClosureScatteringSystem(3, 2, transfer2, boundary2)

    print("System 1: T(x) = (x+1) mod 3")
    print("System 2: relabeled version of System 1")
    print()

    profiles1 = set(S1.all_response_profiles().values())
    profiles2 = set(S2.all_response_profiles().values())

    print(f"S1 separated: {S1.is_separated()}")
    print(f"S2 separated: {S2.is_separated()}")
    print(f"Same profile sets: {profiles1 == profiles2}")
    print()

    # Find the isomorphism
    p1 = S1.all_response_profiles()
    p2 = S2.all_response_profiles()
    iso = {}
    for x1, prof1 in p1.items():
        for x2, prof2 in p2.items():
            if prof1 == prof2:
                iso[x1] = x2
                break

    print("Isomorphism (matching by response profiles):")
    for x1, x2 in iso.items():
        print(f"  S1.state {x1} ↔ S2.state {x2}")

    # Verify isomorphism properties
    print()
    print("Verification:")
    for x1, x2 in iso.items():
        t1 = transfer1(x1)
        t2 = transfer2(x2)
        print(f"  T1({x1})={t1}, T2({x2})={t2}, iso(T1({x1}))={iso[t1]}, "
              f"match: {iso[t1] == t2}")
    print()


def demo_spectral_boundary():
    """Demo 5: Spectral boundary semimodule visualization."""
    print("=" * 70)
    print("DEMO 5: Spectral Boundary Semimodule")
    print("=" * 70)
    print()

    # 3-state system
    transfer = lambda x: (x + 1) % 3
    boundary = lambda x, c: np.sin(x * np.pi / 3 + c * np.pi / 4)

    S = ClosureScatteringSystem(3, 2, transfer, boundary)

    print("System: 3 states, 2 channels, T(x) = (x+1) mod 3")
    print("Boundary: sin-based observations")
    print()

    depth = 8
    profiles = S.all_response_profiles(depth)

    print("Spectral Boundary Semimodule (response profiles):")
    print(f"  Number of profiles: {len(set(profiles.values()))}")
    print()

    for x in range(3):
        p = profiles[x]
        print(f"  Profile of state {x}:")
        for n in range(min(4, depth)):
            vals = ", ".join(f"{v:.3f}" for v in p[n])
            print(f"    n={n}: [{vals}]")

    # Verify shift-closure
    print()
    print("Shift-closure verification:")
    profile_set = set(profiles.values())
    for x in range(3):
        p = profiles[x]
        shifted = p[1:]
        # Check if shifted profile matches some profile (up to truncation)
        tx = transfer(x)
        tx_profile = profiles[tx]
        match = all(p[n+1] == tx_profile[n] for n in range(depth-1))
        print(f"  shift(profile({x})) == profile(T({x})={tx}): {match}")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Closure-Scattering Systems: Minimal Resonance Realization Demo    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_basic_system()
    demo_redundant_system()
    demo_closure_defect()
    demo_uniqueness()
    demo_spectral_boundary()

    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables bundled."""

import json
import os


def read_file(path):
    with open(path, 'r') as f:
        return f.read()


def read_binary_base64(path):
    import base64
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')


def main():
    # Read all content
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    lean_proofs = read_file('Bridges/AlgebraEMLPhysics/ModularScatteringDuality.lean')
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    applications_code = read_file('applications.py')

    # Read visualizations
    viz_data = {}
    for name in ['response_profiles', 'resonance_reduction', 'closure_defect', 'duality_diagram']:
        path = f'{name}.png'
        if os.path.exists(path):
            viz_data[name] = read_binary_base64(path)

    package = {
        "title": "Modular Scattering Duality via Idempotent Closure-Scattering Systems",
        "domain": "Algebraic Scattering Theory / Tropical Algebra / Closure Dynamics",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Closure-Scattering System Demonstrations",
                "code": demo_code
            },
            {
                "name": "Real-World Applications",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Minimal Realization from Response Data",
                "pseudocode": (
                    "Input: CSS S = (cl, T, β) with finite state space X, channel set C\n"
                    "Output: Minimal realization S_min\n\n"
                    "1. For each x ∈ X, compute ρ_S(x) to depth D (D ≥ |X| suffices)\n"
                    "2. Group states by response profile → resonance classes\n"
                    "3. Representatives: one state per class\n"
                    "4. S_min states = set of distinct profiles\n"
                    "5. S_min.T(profile) = shift(profile)\n"
                    "6. S_min.β(profile, c) = profile(0, c)\n"
                    "7. Return S_min\n\n"
                    "Complexity: O(|X| · D · |C|) time, O(|X| · D · |C|) space"
                ),
                "code": algorithms_code
            },
            {
                "name": "Isomorphism Detection between Separated Systems",
                "pseudocode": (
                    "Input: Separated CSS's S₁, S₂ with same channel set C\n"
                    "Output: Isomorphism f : X₁ → X₂ or 'not isomorphic'\n\n"
                    "1. Compute profile sets P₁, P₂\n"
                    "2. If P₁ ≠ P₂, return 'not isomorphic'\n"
                    "3. For each x₁ ∈ X₁, find x₂ ∈ X₂ with ρ(x₂) = ρ(x₁)\n"
                    "4. Return the mapping x₁ ↦ x₂\n\n"
                    "Complexity: O((|X₁|+|X₂|) · D · |C|) time"
                ),
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {
                "name": "Response Profiles of a Closure-Scattering System",
                "data": viz_data.get('response_profiles', '')
            },
            {
                "name": "Resonance Reduction: Original to Minimal Realization",
                "data": viz_data.get('resonance_reduction', '')
            },
            {
                "name": "Closure Defect Analysis (Resonance Detection)",
                "data": viz_data.get('closure_defect', '')
            },
            {
                "name": "Modular Scattering Duality Diagram",
                "data": viz_data.get('duality_diagram', '')
            }
        ],
        "lean_proofs": lean_proofs
    }

    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print(f"Generated PACKAGE.json ({os.path.getsize('PACKAGE.json')} bytes)")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualizations for Closure-Scattering Duality Theory.
Generates figures showing key mathematical structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
import math


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_response_profiles():
    """Visualize response profiles of a closure-scattering system."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # System: 4 states, 2 channels, cyclic transfer
    n_states = 4
    depth = 8
    boundary_vals = [
        [1.0, 0.0], [0.5, 1.0], [0.0, 0.5], [1.0, 0.5]
    ]

    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

    # Panel 1: Response profiles channel 0
    ax = axes[0]
    for s in range(n_states):
        profile = []
        state = s
        for n in range(depth):
            profile.append(boundary_vals[state][0])
            state = (state + 1) % 4
        ax.plot(range(depth), profile, 'o-', color=colors[s],
                label=f'State {s}', linewidth=2, markersize=6)
    ax.set_xlabel('Time step n', fontsize=12)
    ax.set_ylabel('Boundary value', fontsize=12)
    ax.set_title('Channel 0 Response', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 2: Response profiles channel 1
    ax = axes[1]
    for s in range(n_states):
        profile = []
        state = s
        for n in range(depth):
            profile.append(boundary_vals[state][1])
            state = (state + 1) % 4
        ax.plot(range(depth), profile, 's-', color=colors[s],
                label=f'State {s}', linewidth=2, markersize=6)
    ax.set_xlabel('Time step n', fontsize=12)
    ax.set_ylabel('Boundary value', fontsize=12)
    ax.set_title('Channel 1 Response', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 3: Profile similarity heatmap
    ax = axes[2]
    profiles = []
    for s in range(n_states):
        profile = []
        state = s
        for n in range(depth):
            for c in range(2):
                profile.append(boundary_vals[state][c])
            state = (state + 1) % 4
        profiles.append(profile)

    # Compute pairwise distances
    dist = np.zeros((n_states, n_states))
    for i in range(n_states):
        for j in range(n_states):
            dist[i, j] = sum((a - b) ** 2 for a, b in zip(profiles[i], profiles[j])) ** 0.5

    im = ax.imshow(dist, cmap='RdYlGn_r', interpolation='nearest')
    ax.set_xticks(range(n_states))
    ax.set_yticks(range(n_states))
    ax.set_xticklabels([f'State {i}' for i in range(n_states)], fontsize=10)
    ax.set_yticklabels([f'State {i}' for i in range(n_states)], fontsize=10)
    ax.set_title('Profile Distance Matrix', fontsize=14)
    plt.colorbar(im, ax=ax, label='Distance')

    fig.suptitle('Closure-Scattering System: Response Profiles', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_resonance_reduction():
    """Visualize the reduction from original to minimal realization."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Original system: 6 states with redundancy (0≡3, 1≡4, 2≡5)
    ax = axes[0]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')

    # Draw states in two rings
    angles_inner = [0, 2*np.pi/3, 4*np.pi/3]
    angles_outer = [np.pi/6, 2*np.pi/3 + np.pi/6, 4*np.pi/3 + np.pi/6]
    r_inner, r_outer = 0.8, 1.5

    positions = {}
    colors_orig = ['#2196F3', '#FF5722', '#4CAF50', '#2196F3', '#FF5722', '#4CAF50']
    alphas = [1.0, 1.0, 1.0, 0.5, 0.5, 0.5]

    for i, (angle, r) in enumerate(
        [(a, r_inner) for a in angles_inner] +
        [(a, r_outer) for a in angles_outer]
    ):
        x, y = r * np.cos(angle), r * np.sin(angle)
        positions[i] = (x, y)
        circle = plt.Circle((x, y), 0.2, color=colors_orig[i],
                           alpha=alphas[i], ec='black', linewidth=1.5)
        ax.add_patch(circle)
        ax.text(x, y, str(i), ha='center', va='center',
                fontsize=12, fontweight='bold', color='white')

    # Draw transfer arrows
    transfer = [1, 2, 0, 4, 5, 3]
    for i in range(6):
        j = transfer[i]
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        dx, dy = x2 - x1, y2 - y1
        d = (dx**2 + dy**2)**0.5
        dx, dy = dx/d, dy/d
        ax.annotate('', xy=(x2 - 0.22*dx, y2 - 0.22*dy),
                    xytext=(x1 + 0.22*dx, y1 + 0.22*dy),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    # Draw equivalence arcs
    for (i, j) in [(0, 3), (1, 4), (2, 5)]:
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        ax.plot([x1, x2], [y1, y2], '--', color=colors_orig[i],
                linewidth=2, alpha=0.6)

    ax.set_title('Original System (6 states)\nDashed: resonance equivalence', fontsize=13)
    ax.axis('off')

    # Minimal realization: 3 states
    ax = axes[1]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')

    angles_min = [0, 2*np.pi/3, 4*np.pi/3]
    colors_min = ['#2196F3', '#FF5722', '#4CAF50']
    r_min = 1.0

    pos_min = {}
    for i, angle in enumerate(angles_min):
        x, y = r_min * np.cos(angle), r_min * np.sin(angle)
        pos_min[i] = (x, y)
        circle = plt.Circle((x, y), 0.3, color=colors_min[i],
                           alpha=1.0, ec='black', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, f'[{i}]', ha='center', va='center',
                fontsize=14, fontweight='bold', color='white')

    # Transfer arrows
    for i in range(3):
        j = (i + 1) % 3
        x1, y1 = pos_min[i]
        x2, y2 = pos_min[j]
        dx, dy = x2 - x1, y2 - y1
        d = (dx**2 + dy**2)**0.5
        dx, dy = dx/d, dy/d
        ax.annotate('', xy=(x2 - 0.32*dx, y2 - 0.32*dy),
                    xytext=(x1 + 0.32*dx, y1 + 0.32*dy),
                    arrowprops=dict(arrowstyle='->', color='black', lw=2))

    ax.set_title('Minimal Realization (3 states)\nSeparated & shift-closed', fontsize=13)
    ax.axis('off')

    fig.suptitle('Resonance Reduction: From Redundant to Minimal', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_closure_defect():
    """Visualize closure defect as resonance indicator."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    states = list(range(4))
    state_positions = {0: (0, 0), 1: (1, 0), 2: (2, 0), 3: (3, 0)}

    def draw_state_diagram(ax, A, title, defect_states):
        ax.set_xlim(-0.5, 3.5)
        ax.set_ylim(-1.5, 1.5)

        # Draw adjacency (line graph)
        for i in range(3):
            ax.plot([i, i+1], [0, 0], '-', color='gray', linewidth=1, alpha=0.5)

        # Closure region
        cl_A = set(A)
        for x in A:
            if x > 0: cl_A.add(x - 1)
            if x < 3: cl_A.add(x + 1)

        T_A = {(x + 1) % 4 for x in A}
        cl_T_A = set(T_A)
        for x in T_A:
            if x > 0: cl_T_A.add(x - 1)
            if x < 3: cl_T_A.add(x + 1)

        T_cl_A = {(x + 1) % 4 for x in cl_A}

        for i in states:
            x, y = i, 0
            if i in defect_states:
                color = '#FF1744'
                ec = 'red'
                lw = 3
            elif i in A:
                color = '#2196F3'
                ec = 'blue'
                lw = 2
            elif i in cl_A:
                color = '#90CAF9'
                ec = 'blue'
                lw = 1.5
            else:
                color = '#E0E0E0'
                ec = 'gray'
                lw = 1

            circle = plt.Circle((x, y), 0.2, color=color, ec=ec, linewidth=lw)
            ax.add_patch(circle)
            ax.text(x, y, str(i), ha='center', va='center', fontsize=11, fontweight='bold')

        # Labels
        ax.text(1.5, -1.0, f'A = {set(A)}', ha='center', fontsize=10)
        ax.text(1.5, -1.3, f'cl(A) = {cl_A}', ha='center', fontsize=9, color='blue')
        defect_text = set(defect_states) if defect_states else '∅'
        ax.text(1.5, 1.0, f'Defect = {defect_text}', ha='center', fontsize=10,
                color='red' if defect_states else 'green', fontweight='bold')

        ax.set_title(title, fontsize=12)
        ax.axis('off')

    # Example subsets
    subsets = [
        ({0}, "A = {0}"),
        ({1}, "A = {1}"),
        ({0, 2}, "A = {0, 2}"),
        ({1, 3}, "A = {1, 3}"),
    ]

    def compute_defect(A):
        cl_A = set(A)
        for x in A:
            if x > 0: cl_A.add(x - 1)
            if x < 3: cl_A.add(x + 1)
        T_cl_A = {(x + 1) % 4 for x in cl_A}
        T_A = {(x + 1) % 4 for x in A}
        cl_T_A = set(T_A)
        for x in T_A:
            if x > 0: cl_T_A.add(x - 1)
            if x < 3: cl_T_A.add(x + 1)
        return T_cl_A - cl_T_A

    for idx, (A, title) in enumerate(subsets):
        ax = axes[idx // 2][idx % 2]
        defect = compute_defect(A)
        draw_state_diagram(ax, A, title, defect)

    fig.suptitle('Closure Defect Analysis: T(cl(A)) \\ cl(T(A))\n'
                 'Blue = A and cl(A), Red = defect (resonance)',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_duality_diagram():
    """Conceptual diagram of the duality between systems and spectral boundaries."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 7)
    ax.axis('off')

    # Left box: Closure-Scattering System
    rect1 = mpatches.FancyBboxPatch((0.5, 2), 4.5, 4, boxstyle="round,pad=0.3",
                                      facecolor='#E3F2FD', edgecolor='#1565C0', linewidth=2)
    ax.add_patch(rect1)
    ax.text(2.75, 5.5, 'Closure-Scattering\nSystem', ha='center', va='center',
            fontsize=14, fontweight='bold', color='#1565C0')
    ax.text(2.75, 4.3, '• States X', ha='center', fontsize=11)
    ax.text(2.75, 3.7, '• Closure cl', ha='center', fontsize=11)
    ax.text(2.75, 3.1, '• Transfer T', ha='center', fontsize=11)
    ax.text(2.75, 2.5, '• Boundary β', ha='center', fontsize=11)

    # Right box: Spectral Boundary Semimodule
    rect2 = mpatches.FancyBboxPatch((7, 2), 4.5, 4, boxstyle="round,pad=0.3",
                                      facecolor='#FFF3E0', edgecolor='#E65100', linewidth=2)
    ax.add_patch(rect2)
    ax.text(9.25, 5.5, 'Spectral Boundary\nSemimodule', ha='center', va='center',
            fontsize=14, fontweight='bold', color='#E65100')
    ax.text(9.25, 4.3, '• Response profiles', ha='center', fontsize=11)
    ax.text(9.25, 3.7, '• Shift operation', ha='center', fontsize=11)
    ax.text(9.25, 3.1, '• Resonance classes', ha='center', fontsize=11)
    ax.text(9.25, 2.5, '• Evaluation at n=0', ha='center', fontsize=11)

    # Arrows
    ax.annotate('', xy=(6.9, 4.8), xytext=(5.1, 4.8),
                arrowprops=dict(arrowstyle='->', color='#2E7D32', lw=2.5))
    ax.text(6.0, 5.15, 'toSpectralBoundary', ha='center', fontsize=10,
            color='#2E7D32', fontweight='bold')

    ax.annotate('', xy=(5.1, 3.2), xytext=(6.9, 3.2),
                arrowprops=dict(arrowstyle='->', color='#6A1B9A', lw=2.5))
    ax.text(6.0, 2.85, 'minimalRealization', ha='center', fontsize=10,
            color='#6A1B9A', fontweight='bold')

    # Bottom: Key theorem
    rect3 = mpatches.FancyBboxPatch((1.5, 0.3), 9, 1.2, boxstyle="round,pad=0.2",
                                      facecolor='#E8F5E9', edgecolor='#2E7D32', linewidth=2)
    ax.add_patch(rect3)
    ax.text(6.0, 0.9, '⟺  Separated systems with identical profiles are isomorphic  ⟺',
            ha='center', va='center', fontsize=12, fontweight='bold', color='#1B5E20')

    fig.suptitle('Modular Scattering Duality', fontsize=18, fontweight='bold', y=0.98)
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_profiles = viz_response_profiles()
    print(f"Response profiles: {len(b64_profiles)} chars")

    b64_reduction = viz_resonance_reduction()
    print(f"Resonance reduction: {len(b64_reduction)} chars")

    b64_defect = viz_closure_defect()
    print(f"Closure defect: {len(b64_defect)} chars")

    b64_duality = viz_duality_diagram()
    print(f"Duality diagram: {len(b64_duality)} chars")

    print("All visualizations generated successfully.")

    # Save individual PNGs
    for name, data in [("response_profiles", b64_profiles),
                       ("resonance_reduction", b64_reduction),
                       ("closure_defect", b64_defect),
                       ("duality_diagram", b64_duality)]:
        img_data = base64.b64decode(data.split(",")[1])
        with open(f"{name}.png", "wb") as f:
            f.write(img_data)
        print(f"Saved {name}.png")
