#!/usr/bin/env python3
"""
applications.py — Real-world applications of closure–secret-sharing duality.

Demonstrates:
1. Corporate vault access policy design and verification
2. Multi-party computation authorization
3. Access structure comparison and policy minimization
4. Redundancy detection in access policies
"""

from itertools import combinations
from typing import FrozenSet
from algorithms import (
    ClosureOperator, PointedDependencySystem, AccessStructure,
    canonical_compressed_presentation, verify_circuit_theorem,
    _powerset
)


# =============================================================================
# Application 1: Corporate Vault Access Policy
# =============================================================================

def corporate_vault_demo():
    """Design and verify a corporate vault access policy.

    Policy:
    - CEO alone can open the vault
    - CFO + any board member can open the vault
    - Any 3 board members can open the vault
    """
    print("=" * 70)
    print("APPLICATION 1: Corporate Vault Access Policy")
    print("=" * 70)
    print()

    participants = {"CEO", "CFO", "Board1", "Board2", "Board3", "Board4"}
    board = {"Board1", "Board2", "Board3", "Board4"}
    option_set = frozenset({None} | participants)

    def vault_authorized(s: frozenset) -> bool:
        if "CEO" in s:
            return True
        if "CFO" in s and len(s & board) >= 1:
            return True
        if len(s & board) >= 3:
            return True
        return False

    def vault_closure(a: frozenset) -> frozenset:
        parts = frozenset(x for x in a if x is not None)
        if vault_authorized(parts):
            return option_set
        return frozenset(a)

    cl = ClosureOperator(ground_set=option_set, cl=vault_closure)
    access = AccessStructure(participants=participants, authorized=vault_authorized)

    # Verify closure axioms
    print(f"Closure operator valid: {cl.verify()}")
    print(f"Access structure monotone: {access.is_monotone()}")

    # Find minimal authorized sets (= secret-circuits)
    mas = access.minimal_authorized_sets()
    print(f"\nMinimal authorized sets ({len(mas)} total):")
    for m in sorted(mas, key=lambda x: (len(x), sorted(x))):
        print(f"  {sorted(m)}")

    # Verify circuit theorem
    print(f"\nCircuit theorem verified: {verify_circuit_theorem(participants, cl)}")

    # Policy analysis
    print("\nPolicy analysis:")
    print(f"  Smallest coalition size: {min(len(m) for m in mas)}")
    print(f"  Largest coalition size:  {max(len(m) for m in mas)}")

    # Check which participants are essential (appear in all minimal sets)
    essential = set.intersection(*[set(m) for m in mas]) if mas else set()
    print(f"  Essential participants: {essential if essential else 'none'}")

    # Check which participants are redundant (appear in no minimal set)
    in_any = set.union(*[set(m) for m in mas]) if mas else set()
    redundant = participants - in_any
    print(f"  Redundant participants: {redundant if redundant else 'none'}")

    return participants, mas


# =============================================================================
# Application 2: Multi-Party Computation Authorization
# =============================================================================

def mpc_authorization_demo():
    """Multi-party computation: verify that computation can proceed.

    Scenario: 5 parties computing a function. At least 3 must be online
    AND at least one must be from the "validator" group.
    """
    print()
    print("=" * 70)
    print("APPLICATION 2: Multi-Party Computation Authorization")
    print("=" * 70)
    print()

    participants = {"V1", "V2", "C1", "C2", "C3"}
    validators = {"V1", "V2"}
    option_set = frozenset({None} | participants)

    def mpc_authorized(s: frozenset) -> bool:
        return len(s) >= 3 and len(s & validators) >= 1

    def mpc_closure(a: frozenset) -> frozenset:
        parts = frozenset(x for x in a if x is not None)
        if mpc_authorized(parts):
            return option_set
        return frozenset(a)

    cl = ClosureOperator(ground_set=option_set, cl=mpc_closure)
    access = AccessStructure(participants=participants, authorized=mpc_authorized)

    mas = access.minimal_authorized_sets()
    print(f"Minimal authorized coalitions ({len(mas)} total):")
    for m in sorted(mas, key=lambda x: (len(x), sorted(x))):
        print(f"  {sorted(m)}")

    print(f"\nCircuit theorem verified: {verify_circuit_theorem(participants, cl)}")
    print(f"Monotonicity verified: {access.is_monotone()}")

    # Canonical compression
    compressed = canonical_compressed_presentation(participants, mas)
    print("\nCanonical compressed system verification:")
    mismatches = 0
    for s in _powerset(participants):
        orig = mpc_authorized(s)
        comp = compressed.is_authorized(s)
        if orig != comp:
            mismatches += 1
    print(f"  Mismatches: {mismatches}")
    print(f"  Compression preserves authorization: {'✓' if mismatches == 0 else '✗'}")


# =============================================================================
# Application 3: Policy Comparison
# =============================================================================

def policy_comparison_demo():
    """Compare two access policies by their circuit structure.

    Two policies are equivalent iff they have the same minimal authorized sets.
    """
    print()
    print("=" * 70)
    print("APPLICATION 3: Access Policy Comparison")
    print("=" * 70)
    print()

    participants = {"A", "B", "C", "D"}

    # Policy 1: any 2 of {A,B,C,D}
    def policy1(s: frozenset) -> bool:
        return len(s) >= 2

    # Policy 2: (A and B) or (C and D) or (A and C) or (A and D) or (B and C) or (B and D)
    # This is also "any 2 of 4"
    def policy2(s: frozenset) -> bool:
        pairs = [{"A","B"}, {"C","D"}, {"A","C"}, {"A","D"}, {"B","C"}, {"B","D"}]
        return any(frozenset(p) <= s for p in pairs)

    access1 = AccessStructure(participants=participants, authorized=policy1)
    access2 = AccessStructure(participants=participants, authorized=policy2)

    mas1 = access1.minimal_authorized_sets()
    mas2 = access2.minimal_authorized_sets()

    print("Policy 1 minimal auth sets:", [sorted(m) for m in sorted(mas1, key=sorted)])
    print("Policy 2 minimal auth sets:", [sorted(m) for m in sorted(mas2, key=sorted)])

    equivalent = set(mas1) == set(mas2)
    print(f"\nPolicies are equivalent: {'✓ Yes' if equivalent else '✗ No'}")
    print("(Same circuits ⟹ same access structure, by the duality theorem)")

    # Now a genuinely different policy
    # Policy 3: A required, plus at least one other
    def policy3(s: frozenset) -> bool:
        return "A" in s and len(s) >= 2

    access3 = AccessStructure(participants=participants, authorized=policy3)
    mas3 = access3.minimal_authorized_sets()

    print(f"\nPolicy 3 minimal auth sets: {[sorted(m) for m in sorted(mas3, key=sorted)]}")
    equiv13 = set(mas1) == set(mas3)
    print(f"Policy 1 ≡ Policy 3: {'✓ Yes' if equiv13 else '✗ No'}")

    if not equiv13:
        only_in_1 = set(mas1) - set(mas3)
        only_in_3 = set(mas3) - set(mas1)
        if only_in_1:
            print(f"  Circuits only in Policy 1: {[sorted(m) for m in only_in_1]}")
        if only_in_3:
            print(f"  Circuits only in Policy 3: {[sorted(m) for m in only_in_3]}")


# =============================================================================
# Application 4: Redundancy Detection
# =============================================================================

def redundancy_detection_demo():
    """Detect redundant participants in an access structure.

    A participant is redundant if they don't appear in any minimal authorized set,
    meaning they can never be the "critical" member of any coalition.
    """
    print()
    print("=" * 70)
    print("APPLICATION 4: Participant Redundancy Detection")
    print("=" * 70)
    print()

    participants = {"Alice", "Bob", "Charlie", "Dave", "Eve"}

    # Policy: Alice and Bob, or Charlie and Dave
    # Eve is completely redundant!
    def policy(s: frozenset) -> bool:
        if {"Alice", "Bob"} <= s:
            return True
        if {"Charlie", "Dave"} <= s:
            return True
        return False

    access = AccessStructure(participants=participants, authorized=policy)
    mas = access.minimal_authorized_sets()

    print(f"Policy: (Alice ∧ Bob) ∨ (Charlie ∧ Dave)")
    print(f"Participants: {sorted(participants)}")
    print(f"\nMinimal authorized sets:")
    for m in mas:
        print(f"  {sorted(m)}")

    # Find who appears in any circuit
    in_any_circuit = set()
    for m in mas:
        in_any_circuit |= set(m)

    redundant = participants - in_any_circuit
    print(f"\nParticipants in circuits: {sorted(in_any_circuit)}")
    print(f"Redundant participants: {sorted(redundant)}")

    if redundant:
        print(f"\n⚠ Warning: {sorted(redundant)} never contribute to any")
        print(f"  minimal authorized coalition. They can be removed from")
        print(f"  the scheme without changing the access structure.")

    # Irredundancy check: for each participant, is there a circuit they're critical in?
    print(f"\nIrredundancy analysis:")
    for p in sorted(participants):
        critical_in = [m for m in mas if p in m]
        status = "essential" if critical_in else "REDUNDANT"
        print(f"  {p:>10s}: appears in {len(critical_in)} circuit(s) → {status}")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    corporate_vault_demo()
    mpc_authorization_demo()
    policy_comparison_demo()
    redundancy_detection_demo()

    print()
    print("=" * 70)
    print("All applications completed successfully ✓")
    print("=" * 70)
