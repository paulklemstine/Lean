#!/usr/bin/env python3
"""
Applications of Closure–Secret-Sharing Duality

Real-world applications demonstrating how closure-based access structures
can model practical authorization scenarios.
"""

from itertools import combinations
from typing import FrozenSet, List, Dict, Set
import json


# ============================================================
# Application 1: Multi-Factor Authentication Policy
# ============================================================

def mfa_access_structure():
    """
    Model a multi-factor authentication policy as a closure-based access structure.

    Policy: A user can access the system if they provide:
    - Password + any biometric (fingerprint OR face), OR
    - Password + hardware token + SMS code, OR
    - Any 3 out of 5 factors

    Factors: {password=1, fingerprint=2, face=3, token=4, sms=5}
    """
    print("=" * 60)
    print("APPLICATION 1: Multi-Factor Authentication Policy")
    print("=" * 60)

    factors = {1: "Password", 2: "Fingerprint", 3: "FaceID",
               4: "HW Token", 5: "SMS Code"}
    secret = 0  # System access

    # Define closure: a coalition authorizes if it matches any policy rule
    universe = frozenset(range(6))

    def cl(S: FrozenSet[int]) -> FrozenSet[int]:
        S_set = set(S)
        # Rule 1: Password + biometric
        if 1 in S_set and (2 in S_set or 3 in S_set):
            return universe
        # Rule 2: Password + token + SMS
        if {1, 4, 5} <= S_set:
            return universe
        # Rule 3: Any 3 factors
        factor_count = len(S_set - {0})
        if factor_count >= 3:
            return universe
        return S

    participants = [1, 2, 3, 4, 5]

    # Find minimal basis
    basis = []
    for size in range(1, 6):
        for combo in combinations(participants, size):
            S = frozenset(combo)
            if secret in cl(S):
                if not any(B < S for B in basis):
                    basis.append(S)
    # Filter to truly minimal
    basis = [S for S in basis if not any(T < S for T in basis if T != S)]

    print("\nPolicy Rules:")
    print("  1. Password + (Fingerprint OR FaceID)")
    print("  2. Password + HW Token + SMS Code")
    print("  3. Any 3 out of 5 factors")

    print(f"\nMinimal authorized combinations ({len(basis)}):")
    for B in sorted(basis, key=lambda x: (len(x), sorted(x))):
        names = [factors[f] for f in sorted(B)]
        print(f"  {{{', '.join(names)}}}")

    # Test scenarios
    print("\nScenario tests:")
    scenarios = [
        (frozenset({1, 2}), "Password + Fingerprint"),
        (frozenset({1, 3}), "Password + FaceID"),
        (frozenset({2, 3}), "Fingerprint + FaceID (no password)"),
        (frozenset({1, 4, 5}), "Password + Token + SMS"),
        (frozenset({2, 3, 4}), "Three factors (no password)"),
        (frozenset({1}), "Password only"),
    ]
    for coalition, desc in scenarios:
        auth = secret in cl(coalition)
        print(f"  {desc}: {'✓ AUTHORIZED' if auth else '✗ Denied'}")


# ============================================================
# Application 2: Corporate Document Access Control
# ============================================================

def corporate_access_control():
    """
    Model corporate document access with hierarchical roles.

    Roles: CEO=1, CFO=2, CTO=3, VP_Eng=4, VP_Sales=5, Analyst=6
    Policy:
    - CEO alone can access any document
    - CFO + CTO together can access
    - Any C-suite + 2 VPs can access
    - All 3 non-C-suite together can access
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Corporate Document Access Control")
    print("=" * 60)

    roles = {1: "CEO", 2: "CFO", 3: "CTO",
             4: "VP_Eng", 5: "VP_Sales", 6: "Analyst"}
    secret = 0
    c_suite = {1, 2, 3}
    vps = {4, 5}

    universe = frozenset(range(7))

    def cl(S: FrozenSet[int]) -> FrozenSet[int]:
        S_set = set(S)
        if 1 in S_set:  # CEO
            return universe
        if {2, 3} <= S_set:  # CFO + CTO
            return universe
        c_count = len(S_set & c_suite)
        vp_count = len(S_set & vps)
        if c_count >= 1 and vp_count >= 2:  # C-suite + 2 VPs
            return universe
        if {4, 5, 6} <= S_set:  # All non-C-suite
            return universe
        return S

    participants = list(range(1, 7))

    # Extract minimal basis
    all_auth = []
    for size in range(1, 7):
        for combo in combinations(participants, size):
            S = frozenset(combo)
            if secret in cl(S):
                all_auth.append(S)

    basis = [S for S in all_auth
             if not any(T < S for T in all_auth)]

    print(f"\nMinimal authorized combinations ({len(basis)}):")
    for B in sorted(basis, key=lambda x: (len(x), sorted(x))):
        names = [roles[r] for r in sorted(B)]
        print(f"  {{{', '.join(names)}}}")

    print(f"\nTotal authorized coalitions: {len(all_auth)}")
    print(f"Compression: {len(basis)}/{len(all_auth)} = "
          f"{len(basis)/len(all_auth):.1%}")


# ============================================================
# Application 3: Distributed Key Management
# ============================================================

def distributed_key_management():
    """
    Model a distributed key management system where cryptographic keys
    are split among servers with geographic and role diversity requirements.

    Servers: US_Primary=1, US_Backup=2, EU_Primary=3, EU_Backup=4, Asia=5
    Policy:
    - At least one server from each of 2 different regions
    - OR all servers from one region + any backup
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Distributed Key Management")
    print("=" * 60)

    servers = {1: "US_Primary", 2: "US_Backup", 3: "EU_Primary",
               4: "EU_Backup", 5: "Asia"}
    regions = {"US": {1, 2}, "EU": {3, 4}, "Asia": {5}}
    secret = 0

    universe = frozenset(range(6))

    def cl(S: FrozenSet[int]) -> FrozenSet[int]:
        S_set = set(S)
        active_regions = set()
        for name, members in regions.items():
            if S_set & members:
                active_regions.add(name)
        # Rule 1: servers from 2+ regions
        if len(active_regions) >= 2:
            return universe
        # Rule 2: All from one region + any backup
        backups = {2, 4}
        for name, members in regions.items():
            if members <= S_set and S_set & backups:
                return universe
        return S

    participants = list(range(1, 6))

    # Extract minimal basis
    all_auth = []
    for size in range(1, 6):
        for combo in combinations(participants, size):
            S = frozenset(combo)
            if secret in cl(S):
                all_auth.append(S)

    basis = [S for S in all_auth
             if not any(T < S for T in all_auth)]

    print(f"\nMinimal key reconstruction groups ({len(basis)}):")
    for B in sorted(basis, key=lambda x: (len(x), sorted(x))):
        names = [servers[s] for s in sorted(B)]
        print(f"  {{{', '.join(names)}}}")

    print(f"\nTotal valid combinations: {len(all_auth)}")
    print(f"Antichain basis size: {len(basis)}")

    # Geographic diversity analysis
    print("\nGeographic diversity of minimal groups:")
    for B in sorted(basis, key=lambda x: (len(x), sorted(x))):
        active = set()
        for name, members in regions.items():
            if set(B) & members:
                active.add(name)
        names = [servers[s] for s in sorted(B)]
        print(f"  {{{', '.join(names)}}} → regions: {active}")


# ============================================================
# Application 4: Secure Voting / Quorum Systems
# ============================================================

def secure_voting():
    """
    Model a blockchain consensus / secure voting system.

    Validators: v1..v7
    Consensus requires: majority (4 out of 7) OR
                       3 validators including at least 1 from each shard
    Shards: {v1,v2,v3}, {v4,v5}, {v6,v7}
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Blockchain Consensus / Quorum System")
    print("=" * 60)

    validators = {i: f"v{i}" for i in range(1, 8)}
    shards = {"Shard_A": {1, 2, 3}, "Shard_B": {4, 5}, "Shard_C": {6, 7}}
    secret = 0

    universe = frozenset(range(8))

    def cl(S: FrozenSet[int]) -> FrozenSet[int]:
        S_set = set(S) - {0}
        # Majority rule
        if len(S_set) >= 4:
            return universe
        # Cross-shard rule: 3 validators, 1 from each shard
        if len(S_set) >= 3:
            active_shards = sum(1 for members in shards.values()
                                if S_set & members)
            if active_shards == 3:
                return universe
        return S

    participants = list(range(1, 8))

    all_auth = []
    for size in range(1, 8):
        for combo in combinations(participants, size):
            S = frozenset(combo)
            if secret in cl(S):
                all_auth.append(S)

    basis = [S for S in all_auth
             if not any(T < S for T in all_auth)]

    print(f"\nConsensus rules:")
    print(f"  1. Majority: 4 out of 7 validators")
    print(f"  2. Cross-shard: 3 validators from all 3 shards")
    print(f"\nShards: {dict((k, set(v)) for k, v in shards.items())}")
    print(f"\nMinimal quorums ({len(basis)}):")

    # Show first few
    for B in sorted(basis, key=lambda x: (len(x), sorted(x)))[:15]:
        names = [validators[v] for v in sorted(B)]
        shard_info = []
        for sname, members in shards.items():
            if set(B) & members:
                shard_info.append(sname)
        rule = "cross-shard" if len(B) == 3 else "majority"
        print(f"  {{{', '.join(names)}}} ({rule}, {'+'.join(shard_info)})")

    if len(basis) > 15:
        print(f"  ... and {len(basis) - 15} more")

    print(f"\nTotal valid quorums: {len(all_auth)}")
    print(f"Minimal quorums (basis): {len(basis)}")
    print(f"Compression: {len(basis)/len(all_auth):.1%}")


if __name__ == "__main__":
    mfa_access_structure()
    corporate_access_control()
    distributed_key_management()
    secure_voting()

    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Closure–Secret-Sharing Duality: Demonstrations

This module demonstrates the core theorems connecting closure operators,
access structures, and idempotent semimodule realizations through concrete
numerical examples.
"""

from itertools import combinations, chain
from typing import Set, FrozenSet, Callable, List, Tuple, Dict
import json


# ============================================================
# §1. Closure Operators
# ============================================================

def make_linear_closure(n: int) -> Callable[[FrozenSet[int]], FrozenSet[int]]:
    """
    Closure operator on subsets of {0, ..., n-1} modeling linear span:
    cl(S) = S union all elements reachable by 'linear combination'.
    For this demo, cl(S) = S if |S| < 2, else cl(S) = {0,...,n-1}.
    This models a (2,n)-threshold scheme.
    """
    universe = frozenset(range(n))
    def cl(S: FrozenSet[int]) -> FrozenSet[int]:
        if len(S) >= 2:
            return universe
        return S
    return cl


def make_matroid_closure(n: int, circuits: List[FrozenSet[int]]) -> Callable:
    """
    Closure operator from a matroid given by its circuits.
    cl(S) = S ∪ {x : ∃ circuit C with x ∈ C and C\\{x} ⊆ S}
    Applied iteratively to fixed point.
    """
    universe = frozenset(range(n))
    def cl(S: FrozenSet[int]) -> FrozenSet[int]:
        result = set(S)
        changed = True
        while changed:
            changed = False
            for C in circuits:
                for x in C:
                    if x not in result and C - {x} <= result:
                        result.add(x)
                        changed = True
        return frozenset(result)
    return cl


# ============================================================
# §2. Access Structures from Closure
# ============================================================

def closure_authorized(cl, secret: int, participants: FrozenSet[int]) -> bool:
    """Check if a coalition is authorized: secret ∈ cl(participants)."""
    return secret in cl(participants)


def find_minimal_authorized(cl, secret: int, n: int) -> List[FrozenSet[int]]:
    """
    Find all minimal authorized coalitions (the antichain basis).
    This implements the key algorithm from Theorem B.
    """
    all_participants = list(range(n))
    # Remove secret from participants if present
    participants = [p for p in all_participants if p != secret]

    authorized = []
    for size in range(1, len(participants) + 1):
        for combo in combinations(participants, size):
            S = frozenset(combo)
            if closure_authorized(cl, secret, S):
                authorized.append(S)

    # Filter to minimal: keep S if no proper subset of S is authorized
    minimal = []
    for S in authorized:
        is_minimal = True
        for T in authorized:
            if T < S:  # proper subset
                is_minimal = False
                break
        if is_minimal:
            minimal.append(S)

    return minimal


def verify_antichain(basis: List[FrozenSet[int]]) -> bool:
    """Verify the basis is an antichain (no element is a subset of another)."""
    for i, U in enumerate(basis):
        for j, V in enumerate(basis):
            if i != j and U <= V:
                return False
    return True


def verify_authorization_iff_contains_basis(
    cl, secret: int, participants: List[int],
    basis: List[FrozenSet[int]]
) -> bool:
    """
    Verify Theorem B: A is authorized iff A contains some basis element.
    Tests all subsets of participants.
    """
    for size in range(len(participants) + 1):
        for combo in combinations(participants, size):
            A = frozenset(combo)
            auth = closure_authorized(cl, secret, A)
            contains_basis = any(U <= A for U in basis)
            if auth != contains_basis:
                return False
    return True


# ============================================================
# §3. Idempotent Semimodule Realization
# ============================================================

class IdempotentAccessSemimodule:
    """
    An idempotent access semimodule over Bool (OR/AND semiring).
    M = basis → Bool (indicator vectors).
    share(x)[i] = (x ∈ basis[i])
    Authorization: ∃ basis element ⊆ coalition.
    """

    def __init__(self, participants: List[int], basis: List[FrozenSet[int]]):
        self.participants = participants
        self.basis = basis
        self.k = len(basis)  # dimension

    def share(self, x: int) -> List[bool]:
        """Share vector for participant x."""
        return [x in B for B in self.basis]

    def secret_vector(self) -> List[bool]:
        """The secret target: all-True vector would be transversal condition."""
        return [True] * self.k

    def authorized(self, coalition: FrozenSet[int]) -> bool:
        """Check authorization via basis containment."""
        return any(B <= coalition for B in self.basis)

    def minimal_support(self, coalition: FrozenSet[int]) -> FrozenSet[int]:
        """Find a minimal authorized sub-coalition, if authorized."""
        for B in self.basis:
            if B <= coalition:
                return B
        return frozenset()


# ============================================================
# §4. Reconstruction Certificate
# ============================================================

class MinimalReconstructionCertificate:
    """
    A certified minimal reconstruction certificate.
    Packages the antichain basis with correctness and minimality proofs.
    """

    def __init__(self, basis: List[FrozenSet[int]]):
        self.basis = basis

    def is_antichain(self) -> bool:
        return verify_antichain(self.basis)

    def reconstructs(self, A: FrozenSet[int]) -> bool:
        return any(U <= A for U in self.basis)

    def is_certified_minimal(self) -> bool:
        """Every basis element is truly minimal."""
        for U in self.basis:
            for size in range(1, len(U)):
                for combo in combinations(U, size):
                    V = frozenset(combo)
                    if self.reconstructs(V):
                        return False
        return True


# ============================================================
# §5. Demonstrations
# ============================================================

def demo_threshold_scheme():
    """Demo 1: (2,5)-threshold secret sharing scheme."""
    print("=" * 60)
    print("DEMO 1: (2,5)-Threshold Secret Sharing via Closure")
    print("=" * 60)

    n = 6  # 5 participants + 1 secret
    secret = 0
    participants = list(range(1, n))

    # Closure: cl(S) = {0,...,5} if |S| >= 2, else S
    cl = make_linear_closure(n)

    print(f"\nParticipants: {participants}")
    print(f"Secret element: {secret}")
    print(f"Closure model: linear span (threshold-2)")

    # Find minimal authorized basis
    basis = find_minimal_authorized(cl, secret, n)
    print(f"\nMinimal authorized basis ({len(basis)} elements):")
    for B in sorted(basis, key=lambda x: (len(x), sorted(x))):
        print(f"  {set(B)}")

    # Verify properties
    print(f"\nAntichain property: {verify_antichain(basis)}")
    print(f"Authorization ↔ contains basis: "
          f"{verify_authorization_iff_contains_basis(cl, secret, participants, basis)}")

    # Build semimodule
    semimod = IdempotentAccessSemimodule(participants, basis)
    print(f"\nSemimodule dimension: {semimod.k}")
    print("Share vectors:")
    for p in participants:
        print(f"  share({p}) = {semimod.share(p)}")

    # Test some coalitions
    test_coalitions = [
        frozenset({1, 2}), frozenset({3, 4, 5}),
        frozenset({1}), frozenset({2, 3, 4, 5})
    ]
    print("\nAuthorization tests:")
    for S in test_coalitions:
        auth = semimod.authorized(S)
        support = semimod.minimal_support(S) if auth else None
        print(f"  {set(S)}: authorized={auth}"
              + (f", minimal witness={set(support)}" if support else ""))

    # Build certificate
    cert = MinimalReconstructionCertificate(basis)
    print(f"\nReconstruction certificate:")
    print(f"  Antichain: {cert.is_antichain()}")
    print(f"  Certified minimal: {cert.is_certified_minimal()}")
    print(f"  Basis size: {len(cert.basis)}")


def demo_matroid_scheme():
    """Demo 2: Matroid-based access structure (non-threshold)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Matroid-Based Access Structure via Closure")
    print("=" * 60)

    # 4 participants {1,2,3,4}, secret = 0
    # Matroid circuits: {0,1,2}, {0,3,4}, {1,2,3,4}
    # This means: {1,2} or {3,4} can reconstruct, but not {1,3} or {2,4}
    n = 5
    secret = 0
    participants = [1, 2, 3, 4]

    circuits = [
        frozenset({0, 1, 2}),
        frozenset({0, 3, 4}),
        frozenset({1, 2, 3, 4})
    ]
    cl = make_matroid_closure(n, circuits)

    print(f"\nParticipants: {participants}")
    print(f"Secret element: {secret}")
    print(f"Matroid circuits: {[set(c) for c in circuits]}")

    # Find basis
    basis = find_minimal_authorized(cl, secret, n)
    print(f"\nMinimal authorized basis ({len(basis)} elements):")
    for B in sorted(basis, key=lambda x: (len(x), sorted(x))):
        print(f"  {set(B)}")

    # Verify
    print(f"\nAntichain property: {verify_antichain(basis)}")
    print(f"Authorization ↔ contains basis: "
          f"{verify_authorization_iff_contains_basis(cl, secret, participants, basis)}")

    # Certificate
    cert = MinimalReconstructionCertificate(basis)
    print(f"\nReconstruction certificate:")
    print(f"  Antichain: {cert.is_antichain()}")
    print(f"  Certified minimal: {cert.is_certified_minimal()}")

    # Semimodule
    semimod = IdempotentAccessSemimodule(participants, basis)
    print(f"\nSemimodule realization:")
    print(f"  Dimension: {semimod.k}")
    for p in participants:
        print(f"  share({p}) = {semimod.share(p)}")

    # Test coalitions
    print("\nAuthorization tests:")
    all_coalitions = []
    for size in range(1, 5):
        for combo in combinations(participants, size):
            all_coalitions.append(frozenset(combo))
    for S in all_coalitions:
        auth = semimod.authorized(S)
        if auth:
            support = semimod.minimal_support(S)
            print(f"  {str(set(S)):20s}: AUTHORIZED (witness: {set(support)})")
        else:
            print(f"  {str(set(S)):20s}: unauthorized")


def demo_hierarchical_scheme():
    """Demo 3: Hierarchical access structure (manager + employees)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Hierarchical Access Structure")
    print("=" * 60)

    # Manager (M=1) can authorize alone
    # Any 2 employees from {E1=2, E2=3, E3=4} can authorize together
    # Secret = 0
    n = 5
    secret = 0

    # Closure: cl(S) = universe if M ∈ S or |S ∩ {E1,E2,E3}| >= 2
    universe = frozenset(range(n))
    employees = {2, 3, 4}
    manager = 1

    def cl(S: FrozenSet[int]) -> FrozenSet[int]:
        S_set = set(S)
        if manager in S_set or len(S_set & employees) >= 2:
            return universe
        return S

    participants = [1, 2, 3, 4]
    basis = find_minimal_authorized(cl, secret, n)

    print(f"\nParticipants: Manager=1, Employees={{2,3,4}}")
    print(f"Policy: Manager alone OR any 2 employees")
    print(f"\nMinimal authorized basis ({len(basis)} elements):")
    for B in sorted(basis, key=lambda x: (len(x), sorted(x))):
        labels = []
        for x in sorted(B):
            labels.append(f"M" if x == 1 else f"E{x-1}")
        print(f"  {set(B)} = {{{', '.join(labels)}}}")

    print(f"\nAntichain: {verify_antichain(basis)}")
    print(f"Correct: {verify_authorization_iff_contains_basis(cl, secret, participants, basis)}")

    cert = MinimalReconstructionCertificate(basis)
    print(f"Certified minimal: {cert.is_certified_minimal()}")

    semimod = IdempotentAccessSemimodule(participants, basis)
    print(f"\nSemimodule dimension: {semimod.k}")
    print(f"Shares:")
    for p in participants:
        label = "Manager" if p == 1 else f"Employee {p-1}"
        print(f"  {label}: {semimod.share(p)}")


def demo_closure_lattice_statistics():
    """Demo 4: Statistics on closure lattice and access structure complexity."""
    print("\n" + "=" * 60)
    print("DEMO 4: Closure Lattice & Access Structure Statistics")
    print("=" * 60)

    configs = [
        ("(2,4)-threshold", 5, make_linear_closure(5)),
        ("(2,6)-threshold", 7, make_linear_closure(7)),
    ]

    for name, n, cl in configs:
        secret = 0
        participants = list(range(1, n))
        basis = find_minimal_authorized(cl, secret, n)

        # Count authorized vs unauthorized coalitions
        n_auth = 0
        n_total = 0
        for size in range(len(participants) + 1):
            for combo in combinations(participants, size):
                n_total += 1
                if closure_authorized(cl, secret, frozenset(combo)):
                    n_auth += 1

        print(f"\n{name}:")
        print(f"  Participants: {len(participants)}")
        print(f"  Total coalitions: {n_total}")
        print(f"  Authorized: {n_auth}")
        print(f"  Unauthorized: {n_total - n_auth}")
        print(f"  Minimal authorized (basis size): {len(basis)}")
        print(f"  Compression ratio: {len(basis)}/{n_auth} = "
              f"{len(basis)/n_auth:.3f}")


if __name__ == "__main__":
    demo_threshold_scheme()
    demo_matroid_scheme()
    demo_hierarchical_scheme()
    demo_closure_lattice_statistics()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Closure–Secret-Sharing Duality

Generates diagrams showing access structure lattices, antichain bases,
and semimodule share matrices.
"""

import base64
import io
from itertools import combinations
from typing import FrozenSet, List

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def make_threshold_closure(n_total):
    universe = frozenset(range(n_total))
    def cl(S):
        return universe if len(S) >= 2 else S
    return cl


def get_basis(cl, secret, participants):
    all_auth = []
    for size in range(1, len(participants) + 1):
        for combo in combinations(participants, size):
            S = frozenset(combo)
            if secret in cl(S):
                all_auth.append(S)
    return [S for S in all_auth if not any(T < S for T in all_auth)]


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def generate_share_matrix_figure():
    """Generate the share matrix heatmap for a (2,4)-threshold scheme."""
    if not HAS_MPL:
        return None

    participants = [1, 2, 3, 4]
    cl = make_threshold_closure(5)
    basis = get_basis(cl, 0, participants)

    # Build share matrix
    k = len(basis)
    n = len(participants)
    matrix = np.zeros((n, k))
    for j, B in enumerate(sorted(basis)):
        for i, p in enumerate(participants):
            matrix[i, j] = 1 if p in B else 0

    fig, ax = plt.subplots(figsize=(8, 4))
    im = ax.imshow(matrix, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)

    ax.set_xticks(range(k))
    ax.set_xticklabels([str(set(B)) for B in sorted(basis)],
                       rotation=45, ha='right', fontsize=8)
    ax.set_yticks(range(n))
    ax.set_yticklabels([f"P{p}" for p in participants], fontsize=10)

    ax.set_xlabel("Basis Elements (Minimal Authorized Coalitions)", fontsize=11)
    ax.set_ylabel("Participants", fontsize=11)
    ax.set_title("Idempotent Semimodule Share Matrix\n(2,4)-Threshold Scheme",
                 fontsize=13, fontweight='bold')

    # Add text annotations
    for i in range(n):
        for j in range(k):
            text = "1" if matrix[i, j] == 1 else "0"
            color = "white" if matrix[i, j] == 1 else "black"
            ax.text(j, i, text, ha='center', va='center',
                    fontsize=10, color=color, fontweight='bold')

    plt.colorbar(im, ax=ax, shrink=0.8, label="Membership")
    plt.tight_layout()
    return fig


def generate_compression_figure():
    """Generate compression ratio chart across different scheme sizes."""
    if not HAS_MPL:
        return None

    sizes = list(range(3, 10))
    basis_sizes = []
    auth_sizes = []

    for n in sizes:
        cl = make_threshold_closure(n + 1)
        participants = list(range(1, n + 1))
        basis = get_basis(cl, 0, participants)

        n_auth = sum(1 for size in range(n + 1)
                     for combo in combinations(participants, size)
                     if any(B <= frozenset(combo) for B in basis))

        basis_sizes.append(len(basis))
        auth_sizes.append(n_auth)

    ratios = [b / a for b, a in zip(basis_sizes, auth_sizes)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: absolute counts
    ax1.bar([s - 0.15 for s in sizes], auth_sizes, 0.3,
            label='Authorized coalitions', color='steelblue', alpha=0.8)
    ax1.bar([s + 0.15 for s in sizes], basis_sizes, 0.3,
            label='Basis elements', color='coral', alpha=0.8)
    ax1.set_xlabel("Number of Participants", fontsize=11)
    ax1.set_ylabel("Count", fontsize=11)
    ax1.set_title("Authorized Coalitions vs. Basis Size\n(2,n)-Threshold",
                  fontsize=12, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.set_yscale('log')

    # Right: compression ratio
    ax2.plot(sizes, ratios, 'o-', color='darkgreen', linewidth=2, markersize=8)
    ax2.set_xlabel("Number of Participants", fontsize=11)
    ax2.set_ylabel("Compression Ratio (basis/authorized)", fontsize=11)
    ax2.set_title("Certificate Compression Ratio\n(2,n)-Threshold",
                  fontsize=12, fontweight='bold')
    ax2.set_ylim(0, 1)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig


def generate_access_structure_diagram():
    """Generate a Hasse diagram of the access structure lattice."""
    if not HAS_MPL:
        return None

    participants = [1, 2, 3]
    cl = make_threshold_closure(4)
    basis = get_basis(cl, 0, participants)

    # All subsets
    all_subsets = []
    for size in range(4):
        for combo in combinations(participants, size):
            all_subsets.append(frozenset(combo))

    # Classify
    authorized = [S for S in all_subsets if 0 in cl(S)]
    unauthorized = [S for S in all_subsets if S not in authorized]
    minimal = basis

    fig, ax = plt.subplots(figsize=(10, 7))

    # Position by level (size)
    levels = {}
    for S in all_subsets:
        sz = len(S)
        if sz not in levels:
            levels[sz] = []
        levels[sz].append(S)

    positions = {}
    for level, subsets in levels.items():
        n_items = len(subsets)
        for i, S in enumerate(subsets):
            x = (i - (n_items - 1) / 2) * 2.5
            y = level * 2.5
            positions[S] = (x, y)

    # Draw edges (Hasse diagram)
    for S in all_subsets:
        for T in all_subsets:
            if S < T and len(T) == len(S) + 1:
                sx, sy = positions[S]
                tx, ty = positions[T]
                ax.plot([sx, tx], [sy, ty], 'k-', alpha=0.2, linewidth=1)

    # Draw nodes
    for S in all_subsets:
        x, y = positions[S]
        if S in minimal:
            color = '#FF6B35'  # Orange for minimal authorized
            size = 600
            edgecolor = 'darkred'
        elif S in authorized:
            color = '#4ECDC4'  # Teal for authorized
            size = 400
            edgecolor = 'darkgreen'
        else:
            color = '#E8E8E8'  # Gray for unauthorized
            size = 300
            edgecolor = 'gray'

        ax.scatter(x, y, s=size, c=color, edgecolors=edgecolor,
                   linewidth=2, zorder=5)

        label = str(set(S)) if S else "∅"
        ax.annotate(label, (x, y), textcoords="offset points",
                    xytext=(0, -22), ha='center', fontsize=8, fontweight='bold')

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#FF6B35', edgecolor='darkred',
                       label='Minimal Authorized (Basis)'),
        mpatches.Patch(facecolor='#4ECDC4', edgecolor='darkgreen',
                       label='Authorized'),
        mpatches.Patch(facecolor='#E8E8E8', edgecolor='gray',
                       label='Unauthorized'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=10)

    ax.set_title("Access Structure Lattice: (2,3)-Threshold Scheme\n"
                 "Hasse Diagram with Antichain Basis Highlighted",
                 fontsize=13, fontweight='bold')
    ax.set_xlim(-5, 5)
    ax.axis('off')
    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualization figures and return as base64 dict."""
    results = {}

    fig1 = generate_share_matrix_figure()
    if fig1:
        results['share_matrix'] = fig_to_base64(fig1)
        fig1.savefig('/workspace/request-project/share_matrix.png',
                     dpi=150, bbox_inches='tight')
        plt.close(fig1)
        print("Generated: share_matrix.png")

    fig2 = generate_compression_figure()
    if fig2:
        results['compression'] = fig_to_base64(fig2)
        fig2.savefig('/workspace/request-project/compression.png',
                     dpi=150, bbox_inches='tight')
        plt.close(fig2)
        print("Generated: compression.png")

    fig3 = generate_access_structure_diagram()
    if fig3:
        results['access_structure'] = fig_to_base64(fig3)
        fig3.savefig('/workspace/request-project/access_structure.png',
                     dpi=150, bbox_inches='tight')
        plt.close(fig3)
        print("Generated: access_structure.png")

    return results


if __name__ == "__main__":
    viz = generate_all_visualizations()
    print(f"\nGenerated {len(viz)} visualizations")
    for name, data in viz.items():
        print(f"  {name}: {len(data)} chars (base64)")
