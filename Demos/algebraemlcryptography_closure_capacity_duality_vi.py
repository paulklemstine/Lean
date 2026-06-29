#!/usr/bin/env python3
"""
Applications of Closure-Capacity Secret-Sharing Duality

Real-world applications demonstrating the practical relevance of the theory:
1. Multi-factor authentication design
2. Distributed key management for cloud systems
3. Organizational access policy verification
4. Information-theoretic share size bounds
"""

import itertools
from typing import FrozenSet, Set, List, Dict

Element = int
Coalition = FrozenSet[Element]


# ============================================================
# Application 1: Multi-Factor Authentication Design
# ============================================================

def multi_factor_auth():
    """
    Design a multi-factor authentication system using closure-capacity theory.

    Factors: password (P), biometric (B), hardware token (H), phone OTP (O)
    Policy: Need at least 2 factors, but password alone is never sufficient.

    We model this as a closure-capacity system where:
    - cl captures factor interactions (biometric + token generates full trust)
    - cap measures authentication strength
    - Threshold t = 3 requires sufficient combined strength
    """
    print("=" * 60)
    print("APPLICATION 1: Multi-Factor Authentication Design")
    print("=" * 60)

    # Factors: 0=password, 1=biometric, 2=hardware_token, 3=phone_otp
    factors = {0, 1, 2, 3}
    names = {0: "password", 1: "biometric", 2: "hw_token", 3: "phone_otp"}
    X = frozenset(factors)

    # Strength weights
    weights = {0: 1, 1: 2, 2: 2, 3: 1}

    # Closure: biometric + hardware = full trust; password is independent
    def cl(A):
        A_set = set(A)
        if {1, 2} <= A_set:  # biometric + hardware = maximum trust
            return X
        return frozenset(A)

    def cap(A):
        return sum(weights.get(x, 0) for x in A)

    threshold = 3

    # Analyze access structure
    print(f"\nFactors: {', '.join(f'{names[k]}(w={weights[k]})' for k in sorted(factors))}")
    print(f"Threshold: {threshold}")

    # Find minimal authorized factor combinations
    minimals = []
    for r in range(1, len(factors) + 1):
        for combo in itertools.combinations(sorted(factors), r):
            A = frozenset(combo)
            if threshold <= cap(cl(A)):
                # Check minimality
                is_min = all(
                    cap(cl(A - {x})) < threshold for x in A
                )
                if is_min:
                    minimals.append(A)

    print(f"\nMinimal sufficient factor combinations:")
    for M in minimals:
        named = [names[x] for x in sorted(M)]
        strength = cap(cl(M))
        print(f"  {named} → strength {strength} ≥ {threshold} ✓")

    # Show unauthorized combinations
    print(f"\nInsufficient factor combinations (examples):")
    insufficient = []
    for r in range(1, 3):
        for combo in itertools.combinations(sorted(factors), r):
            A = frozenset(combo)
            if cap(cl(A)) < threshold:
                insufficient.append(A)
    for A in insufficient[:6]:
        named = [names[x] for x in sorted(A)]
        print(f"  {named} → strength {cap(cl(A))} < {threshold} ✗")


# ============================================================
# Application 2: Distributed Key Management
# ============================================================

def distributed_key_management():
    """
    Design a distributed key management system for a cloud service.

    Nodes: 3 data centers (DC1, DC2, DC3), 2 admin nodes (A1, A2)
    Policy:
    - Any 2 data centers can reconstruct the master key
    - Any admin + any data center can reconstruct
    - No single node can reconstruct alone
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Distributed Key Management")
    print("=" * 60)

    # Nodes: 0=DC1, 1=DC2, 2=DC3, 3=Admin1, 4=Admin2
    nodes = {0, 1, 2, 3, 4}
    names = {0: "DC1", 1: "DC2", 2: "DC3", 3: "Admin1", 4: "Admin2"}
    X = frozenset(nodes)

    # Weights: DCs have weight 1, Admins have weight 1.5
    weights = {0: 2, 1: 2, 2: 2, 3: 3, 4: 3}

    # Closure: admin presence extends to include all DCs they manage
    def cl(A):
        A_set = set(A)
        # Admin sees all data centers
        if {3, 4} & A_set:  # any admin present
            return frozenset(A_set | {0, 1, 2})
        return frozenset(A)

    def cap(A):
        return sum(weights.get(x, 0) for x in A)

    threshold = 4

    print(f"\nNodes: {', '.join(f'{names[k]}(w={weights[k]})' for k in sorted(nodes))}")
    print(f"Threshold: {threshold}")

    # Find and display access structure
    minimals = []
    for r in range(1, len(nodes) + 1):
        for combo in itertools.combinations(sorted(nodes), r):
            A = frozenset(combo)
            if threshold <= cap(cl(A)):
                is_min = all(cap(cl(A - {x})) < threshold for x in A)
                if is_min:
                    minimals.append(A)

    print(f"\nMinimal reconstruction coalitions:")
    for M in minimals:
        named = [names[x] for x in sorted(M)]
        print(f"  {named} → cap = {cap(cl(M))}")

    # Verify security property: no single node can reconstruct
    print(f"\nSecurity verification:")
    for x in sorted(nodes):
        single = frozenset({x})
        strength = cap(cl(single))
        safe = strength < threshold
        print(f"  {names[x]} alone: cap = {strength} {'< ' + str(threshold) + ' ✓ secure' if safe else '≥ ' + str(threshold) + ' ✗ INSECURE'}")


# ============================================================
# Application 3: Organizational Access Policy Verification
# ============================================================

def access_policy_verification():
    """
    Verify that an organizational access policy is consistent and complete.

    Uses closure-capacity framework to check:
    1. Upward closure (adding people never removes access)
    2. Minimal authorized sets are irredundant
    3. Reconstruction data is correct
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Organizational Access Policy Verification")
    print("=" * 60)

    # Organization: CEO, CFO, CTO, Engineer, Accountant
    people = {0, 1, 2, 3, 4}
    names = {0: "CEO", 1: "CFO", 2: "CTO", 3: "Engineer", 4: "Accountant"}

    # Policy: access to financial records
    # - CEO alone
    # - CFO + any other officer (CTO)
    # - CFO + Accountant
    # - CTO + Engineer + Accountant (cross-department)
    minimal_auth_sets = [
        frozenset({0}),           # CEO alone
        frozenset({1, 2}),        # CFO + CTO
        frozenset({1, 4}),        # CFO + Accountant
        frozenset({2, 3, 4}),     # CTO + Engineer + Accountant
    ]

    print(f"\nPeople: {', '.join(f'{names[k]}' for k in sorted(people))}")
    print(f"\nDeclared minimal authorized sets:")
    for M in minimal_auth_sets:
        print(f"  {[names[x] for x in sorted(M)]}")

    # Construct identity realization
    def cl(A):
        return A

    def cap(A):
        return 1 if any(M <= A for M in minimal_auth_sets) else 0

    threshold = 1

    # Verify properties
    # 1. Upward closure
    upward_ok = True
    for r in range(len(people) + 1):
        for combo in itertools.combinations(sorted(people), r):
            A = frozenset(combo)
            if cap(cl(A)) >= threshold:
                for x in people - A:
                    B = A | {x}
                    if cap(cl(B)) < threshold:
                        upward_ok = False
                        print(f"  ✗ Upward closure violated: {set(A)} authorized but {set(B)} not!")

    print(f"\n1. Upward closure: {'✓ verified' if upward_ok else '✗ VIOLATED'}")

    # 2. Minimality check
    all_minimal = True
    for M in minimal_auth_sets:
        for x in M:
            sub = M - {x}
            if cap(cl(sub)) >= threshold:
                all_minimal = False
                print(f"  ✗ {[names[y] for y in sorted(M)]} is not minimal: "
                      f"removing {names[x]} still authorized")

    print(f"2. All declared minimals are truly minimal: {'✓ verified' if all_minimal else '✗ VIOLATED'}")

    # 3. Count total authorized coalitions
    total_auth = sum(1 for A in itertools.chain.from_iterable(
        itertools.combinations(sorted(people), r) for r in range(len(people) + 1)
    ) if cap(cl(frozenset(A))) >= threshold)

    print(f"3. Total authorized coalitions: {total_auth} out of {2**len(people)}")

    # 4. Identify unauthorized key people
    print(f"\n4. Individual access analysis:")
    for x in sorted(people):
        solo = frozenset({x})
        auth = cap(cl(solo)) >= threshold
        # How many coalitions need this person
        needed_in = sum(1 for M in minimal_auth_sets if x in M)
        print(f"  {names[x]:12s}: solo={'✓' if auth else '✗'}, "
              f"appears in {needed_in}/{len(minimal_auth_sets)} minimal sets")


# ============================================================
# Application 4: Share Size Lower Bounds
# ============================================================

def share_size_bounds():
    """
    Compute information-theoretic lower bounds on share sizes
    using submodular capacity analysis.

    For a k-out-of-n threshold scheme, the minimum share size
    equals the secret size (information-theoretic optimality of
    Shamir's scheme).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Information-Theoretic Share Size Bounds")
    print("=" * 60)

    for n in range(3, 8):
        for k in range(2, n):
            universe = set(range(n))
            X = frozenset(universe)

            def make_cl(k_val, X_val):
                def cl(A):
                    return X_val if len(A) >= k_val else frozenset(A)
                return cl

            cl = make_cl(k, X)
            cap_fn = lambda A: min(len(A), k)

            # Count minimal authorized sets
            minimals = []
            for combo in itertools.combinations(sorted(universe), k):
                A = frozenset(combo)
                if k <= cap_fn(cl(A)):
                    is_min = all(cap_fn(cl(A - {x})) < k for x in A)
                    if is_min:
                        minimals.append(A)

            # Submodularity bound: for any participant x,
            # share size ≥ secret_size * (min capacity gap)
            min_gap = float('inf')
            for x in universe:
                for M in minimals:
                    if x in M:
                        without = M - {x}
                        gap = cap_fn(cl(M)) - cap_fn(cl(without))
                        min_gap = min(min_gap, gap)

            print(f"  {k}-out-of-{n}: "
                  f"{len(minimals):4d} minimal sets, "
                  f"min capacity gap = {min_gap}, "
                  f"share/secret ratio ≥ {1.0/max(min_gap, 1):.2f}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Applications of Closure-Capacity Secret-Sharing Duality")
    print("=" * 60)

    multi_factor_auth()
    distributed_key_management()
    access_policy_verification()
    share_size_bounds()

    print("\n" + "=" * 60)
    print("All applications complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Create PACKAGE.json with all artifacts."""
import json

# Read all files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Bridges/AlgebraEMLCryptography/ClosureCapacitySecretSharingDuality.lean')
access_svg = read_file('access_structure.svg')
closure_svg = read_file('closure_basis.svg')

package = {
    "title": "Closure-Capacity Secret-Sharing Duality",
    "domain": "Bridges (Algebra–EML–Cryptography)",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Closure-Capacity Secret-Sharing Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Authorized Coalition Enumeration",
            "pseudocode": "Algorithm: EnumerateAuthorized(X, cl, cap, t)\nInput: Finite set X, closure operator cl, capacity cap, threshold t\nOutput: Set of all authorized coalitions\n\n1. For each subset A ⊆ X:\n2.   Compute cl(A)\n3.   Compute cap(cl(A))\n4.   If t ≤ cap(cl(A)), add A to output\n5. Return output\n\nTime complexity: O(2^n · T_cl · T_cap)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Access Structure: 3-out-of-5 Threshold Scheme",
            "data": access_svg
        },
        {
            "name": "Closure Basis Concept",
            "data": closure_svg
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json created ({len(json.dumps(package))} bytes)")


#!/usr/bin/env python3
"""
Closure-Capacity Secret-Sharing Duality: Demonstrations

This script demonstrates the core theorems connecting closure operators,
monotone capacities, and cryptographic access structures.

Examples:
  1. Threshold secret sharing (k-out-of-n) via closure-capacity systems
  2. Hierarchical access structures from lattice closures
  3. Minimal authorized set enumeration
  4. Reconstruction data extraction
"""

import itertools
from typing import Callable, FrozenSet, Set, List, Dict, Tuple

# Type aliases
Element = int
Coalition = FrozenSet[Element]


# ============================================================
# §1. Closure Operators
# ============================================================

class ClosureOperator:
    """A closure operator on subsets of a finite set."""

    def __init__(self, universe: Set[Element], cl: Callable[[FrozenSet[Element]], FrozenSet[Element]]):
        self.universe = frozenset(universe)
        self._cl = cl
        self._validate()

    def _validate(self):
        """Verify closure operator axioms on small cases."""
        subsets = list(self._powerset_up_to(min(len(self.universe), 5)))
        for A in subsets:
            clA = self._cl(A)
            # Extensive: A ⊆ cl(A)
            assert A <= clA, f"Not extensive: {A} ⊄ cl({A})={clA}"
            # Idempotent: cl(cl(A)) = cl(A)
            assert self._cl(clA) == clA, f"Not idempotent at {A}"

    def _powerset_up_to(self, max_size):
        elems = sorted(self.universe)[:max_size]
        for r in range(len(elems) + 1):
            for combo in itertools.combinations(elems, r):
                yield frozenset(combo)

    def cl(self, A: FrozenSet[Element]) -> FrozenSet[Element]:
        return self._cl(A)

    def is_closed(self, A: FrozenSet[Element]) -> bool:
        return self.cl(A) == A

    def closed_sets(self) -> List[FrozenSet[Element]]:
        """Enumerate all closed sets."""
        result = []
        for r in range(len(self.universe) + 1):
            for combo in itertools.combinations(sorted(self.universe), r):
                s = frozenset(combo)
                if self.is_closed(s):
                    result.append(s)
        return result


# ============================================================
# §2. Closure-Capacity Systems
# ============================================================

class ClosureCapacitySystem:
    """A closure-capacity system (X, cl, cap, t)."""

    def __init__(self, cl_op: ClosureOperator,
                 cap: Callable[[FrozenSet[Element]], float],
                 threshold: float):
        self.cl_op = cl_op
        self.cap = cap
        self.threshold = threshold
        self.universe = cl_op.universe

    def is_authorized(self, A: FrozenSet[Element]) -> bool:
        """Check if coalition A is authorized: t ≤ cap(cl(A))."""
        return self.threshold <= self.cap(self.cl_op.cl(A))

    def authorized_sets(self) -> List[FrozenSet[Element]]:
        """Enumerate all authorized coalitions."""
        result = []
        for r in range(len(self.universe) + 1):
            for combo in itertools.combinations(sorted(self.universe), r):
                A = frozenset(combo)
                if self.is_authorized(A):
                    result.append(A)
        return result

    def minimal_authorized_sets(self) -> List[FrozenSet[Element]]:
        """Find all minimal authorized coalitions."""
        auth = self.authorized_sets()
        minimals = []
        for A in auth:
            is_minimal = True
            for B in auth:
                if B < A:  # B is a proper subset of A
                    is_minimal = False
                    break
            if is_minimal:
                minimals.append(A)
        return minimals

    def is_closure_basis(self, B: FrozenSet[Element]) -> bool:
        """Check if B is a closure basis for cl(B)."""
        clB = self.cl_op.cl(B)
        for elem in B:
            B_minus = B - {elem}
            if self.cl_op.cl(B_minus) == clB:
                return False
        return True

    def verify_upward_closure(self) -> bool:
        """Verify that the authorized family is upward-closed (Theorem 1a)."""
        auth = set(map(frozenset, self.authorized_sets()))
        for A in auth:
            for x in self.universe - A:
                B = A | {x}
                if B not in auth:
                    return False
        return True

    def verify_minimal_are_bases(self) -> bool:
        """Verify that minimal authorized sets are closure bases (Theorem 1b)."""
        for M in self.minimal_authorized_sets():
            if not self.is_closure_basis(M):
                return False
        return True


# ============================================================
# §3. Reconstruction Data
# ============================================================

class ReconstructionData:
    """Certified reconstruction data for an access structure."""

    def __init__(self, minimal_auth: List[FrozenSet[Element]]):
        self.minimal_auth = minimal_auth

    def score(self, A: FrozenSet[Element]) -> int:
        """Score = 1 if A contains some minimal authorized set, else 0."""
        for M in self.minimal_auth:
            if M <= A:
                return 1
        return 0

    def reconstructs(self, system: ClosureCapacitySystem) -> bool:
        """Verify reconstruction correctness (Theorem 3)."""
        for r in range(len(system.universe) + 1):
            for combo in itertools.combinations(sorted(system.universe), r):
                A = frozenset(combo)
                auth = system.is_authorized(A)
                recon = (1 <= self.score(A))
                if auth != recon:
                    return False
        return True


# ============================================================
# §4. Example: k-out-of-n Threshold Secret Sharing
# ============================================================

def threshold_closure(n: int, k: int):
    """
    Construct a closure-capacity system for k-out-of-n threshold secret sharing.

    cl(A) = X if |A| ≥ k, else A  (trivial closure below threshold)
    cap(A) = |A|
    t = k
    """
    universe = set(range(1, n + 1))
    X = frozenset(universe)

    def cl(A: FrozenSet[Element]) -> FrozenSet[Element]:
        if len(A) >= k:
            return X
        return A

    def cap(A: FrozenSet[Element]) -> float:
        return len(A)

    cl_op = ClosureOperator(universe, cl)
    return ClosureCapacitySystem(cl_op, cap, threshold=k)


def demo_threshold():
    """Demo: 3-out-of-5 threshold secret sharing."""
    print("=" * 60)
    print("DEMO 1: 3-out-of-5 Threshold Secret Sharing")
    print("=" * 60)

    system = threshold_closure(n=5, k=3)

    print(f"\nUniverse: {sorted(system.universe)}")
    print(f"Threshold: {system.threshold}")

    # Verify upward closure
    print(f"\nUpward-closed (Theorem 1a): {system.verify_upward_closure()}")

    # Minimal authorized sets
    minimals = system.minimal_authorized_sets()
    print(f"\nMinimal authorized sets ({len(minimals)} total):")
    for M in sorted(minimals, key=lambda s: (len(s), sorted(s))):
        print(f"  {set(M)} — closure basis: {system.is_closure_basis(M)}")

    # Verify minimal = closure basis
    print(f"\nAll minimals are closure bases (Theorem 1b): "
          f"{system.verify_minimal_are_bases()}")

    # Reconstruction
    recon = ReconstructionData(minimals)
    print(f"\nReconstruction correctness (Theorem 3): "
          f"{recon.reconstructs(system)}")

    # Example authorized/unauthorized sets
    print("\nExample coalitions:")
    examples = [
        frozenset({1, 2}),
        frozenset({1, 2, 3}),
        frozenset({3, 4, 5}),
        frozenset({1}),
        frozenset({1, 2, 3, 4, 5}),
    ]
    for A in examples:
        auth = "✓ authorized" if system.is_authorized(A) else "✗ unauthorized"
        print(f"  {str(set(A)):20s} → {auth}")


# ============================================================
# §5. Example: Hierarchical Access Structure
# ============================================================

def hierarchical_closure():
    """
    Construct a hierarchical access structure:
    - Participants: {mgr, eng1, eng2, intern1, intern2}
    - Manager alone can access (weight 3)
    - Two engineers can access (weight 1 each, need 2)
    - Interns need manager or both engineers present

    cl models organizational hierarchy:
    cl({mgr, ...}) always includes the full team
    """
    participants = {0, 1, 2, 3, 4}  # mgr, eng1, eng2, intern1, intern2
    X = frozenset(participants)

    weights = {0: 3, 1: 1, 2: 1, 3: 0, 4: 0}  # mgr=3, eng=1, intern=0

    def cl(A: FrozenSet[Element]) -> FrozenSet[Element]:
        """Hierarchical closure: manager generates whole team."""
        A_set = set(A)
        if 0 in A_set:  # manager present → full closure
            return X
        if {1, 2} <= A_set:  # both engineers → include interns
            return frozenset(A_set | {3, 4})
        return frozenset(A)

    def cap(A: FrozenSet[Element]) -> float:
        return sum(weights.get(x, 0) for x in A)

    cl_op = ClosureOperator(participants, cl)
    return ClosureCapacitySystem(cl_op, cap, threshold=2)


def demo_hierarchical():
    """Demo: Hierarchical access structure."""
    print("\n" + "=" * 60)
    print("DEMO 2: Hierarchical Access Structure")
    print("=" * 60)

    names = {0: "mgr", 1: "eng1", 2: "eng2", 3: "int1", 4: "int2"}
    system = hierarchical_closure()

    print(f"\nParticipants: {', '.join(f'{v}({k})' for k,v in sorted(names.items()))}")
    print(f"Threshold: {system.threshold}")

    print(f"\nUpward-closed (Theorem 1a): {system.verify_upward_closure()}")

    minimals = system.minimal_authorized_sets()
    print(f"\nMinimal authorized sets ({len(minimals)} total):")
    for M in sorted(minimals, key=lambda s: (len(s), sorted(s))):
        named = {names[x] for x in M}
        print(f"  {named} — basis: {system.is_closure_basis(M)}")

    print(f"\nAll minimals are closure bases (Theorem 1b): "
          f"{system.verify_minimal_are_bases()}")

    recon = ReconstructionData(minimals)
    print(f"Reconstruction correctness (Theorem 3): "
          f"{recon.reconstructs(system)}")


# ============================================================
# §6. Example: Realization of an arbitrary access structure
# ============================================================

def demo_realization():
    """Demo: Constructing closure-capacity from an access structure (Theorem 2)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Realization Theorem")
    print("=" * 60)

    # Define an access structure by its minimal authorized sets
    universe = {1, 2, 3, 4}
    min_auth = [
        frozenset({1, 2}),
        frozenset({2, 3}),
        frozenset({1, 3, 4}),
    ]

    print(f"\nUniverse: {sorted(universe)}")
    print(f"Minimal authorized sets: {[set(M) for M in min_auth]}")

    # Construct closure-capacity realization (identity closure, boolean capacity)
    X = frozenset(universe)

    def cl(A):
        return A  # identity closure

    def cap(A):
        for M in min_auth:
            if M <= A:
                return 1
        return 0

    cl_op = ClosureOperator(universe, cl)
    system = ClosureCapacitySystem(cl_op, cap, threshold=1)

    # Verify
    computed_minimals = system.minimal_authorized_sets()
    print(f"\nComputed minimal authorized: {[set(M) for M in sorted(computed_minimals, key=lambda s: (len(s), sorted(s)))]}")
    print(f"Match: {set(map(frozenset, min_auth)) == set(computed_minimals)}")
    print(f"Upward-closed: {system.verify_upward_closure()}")

    recon = ReconstructionData(computed_minimals)
    print(f"Reconstruction correctness: {recon.reconstructs(system)}")

    # Show full access structure
    auth = system.authorized_sets()
    print(f"\nFull authorized family ({len(auth)} sets):")
    for A in sorted(auth, key=lambda s: (len(s), sorted(s))):
        is_min = A in set(computed_minimals)
        marker = " ← minimal" if is_min else ""
        print(f"  {set(A)}{marker}")


# ============================================================
# §7. Submodularity Demo
# ============================================================

def demo_submodularity():
    """Demo: Submodular capacity exchange (Theorem on submodularity)."""
    print("\n" + "=" * 60)
    print("DEMO 4: Submodular Capacity Exchange")
    print("=" * 60)

    # Rank function of uniform matroid U_{2,4}: cap(A) = min(|A|, 2)
    universe = {1, 2, 3, 4}
    X = frozenset(universe)

    def cl(A):
        if len(A) >= 2:
            return X
        return frozenset(A)

    def cap(A):
        return min(len(A), 2)

    cl_op = ClosureOperator(universe, cl)
    t = 2

    # Verify submodularity
    print("\nCapacity function: cap(A) = min(|A|, 2) (rank of U_{2,4})")
    print(f"Threshold t = {t}")

    submodular = True
    for r1 in range(len(universe) + 1):
        for c1 in itertools.combinations(sorted(universe), r1):
            A = frozenset(c1)
            for r2 in range(len(universe) + 1):
                for c2 in itertools.combinations(sorted(universe), r2):
                    B = frozenset(c2)
                    lhs = cap(cl_op.cl(A | B)) + cap(cl_op.cl(A & B))
                    rhs = cap(cl_op.cl(A)) + cap(cl_op.cl(B))
                    if lhs > rhs:
                        submodular = False

    print(f"Submodular on closures: {submodular}")

    # Demonstrate exchange theorem
    print("\nExchange theorem examples (A,B unauthorized, A∪B authorized):")
    for r1 in range(1, len(universe)):
        for c1 in itertools.combinations(sorted(universe), r1):
            A = frozenset(c1)
            for r2 in range(1, len(universe)):
                for c2 in itertools.combinations(sorted(universe), r2):
                    B = frozenset(c2)
                    capA = cap(cl_op.cl(A))
                    capB = cap(cl_op.cl(B))
                    capAB = cap(cl_op.cl(A | B))
                    if capAB >= t and capA < t and capB < t:
                        bound = capA + capB
                        print(f"  A={set(A)}, B={set(B)}: "
                              f"cap(A)={capA}, cap(B)={capB}, "
                              f"sum={bound} < 2t={2*t} ✓")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Closure-Capacity Secret-Sharing Duality: Demonstrations")
    print("=" * 60)
    print()

    demo_threshold()
    demo_hierarchical()
    demo_realization()
    demo_submodularity()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for closure-capacity secret-sharing duality."""

import itertools
import base64
import io

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def generate_access_structure_svg():
    """Generate SVG diagram of a 3-out-of-5 access structure lattice."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" width="600" height="500" viewBox="0 0 600 500">
  <style>
    .auth { fill: #2ecc71; stroke: #27ae60; stroke-width: 2; }
    .unauth { fill: #e74c3c; stroke: #c0392b; stroke-width: 2; }
    .minimal { fill: #f39c12; stroke: #e67e22; stroke-width: 3; }
    .label { font-family: monospace; font-size: 11px; text-anchor: middle; fill: white; font-weight: bold; }
    .title { font-family: sans-serif; font-size: 16px; text-anchor: middle; fill: #2c3e50; font-weight: bold; }
    .legend { font-family: sans-serif; font-size: 12px; fill: #2c3e50; }
    .arrow { stroke: #95a5a6; stroke-width: 1; fill: none; }
  </style>

  <text x="300" y="30" class="title">Access Structure: 3-out-of-5 Threshold Scheme</text>

  <!-- Level 0: empty set -->
  <circle cx="300" cy="460" r="18" class="unauth"/>
  <text x="300" y="465" class="label">∅</text>

  <!-- Level 1: singletons -->
  <circle cx="100" cy="380" r="18" class="unauth"/>
  <text x="100" y="385" class="label">{1}</text>
  <circle cx="200" cy="380" r="18" class="unauth"/>
  <text x="200" y="385" class="label">{2}</text>
  <circle cx="300" cy="380" r="18" class="unauth"/>
  <text x="300" y="385" class="label">{3}</text>
  <circle cx="400" cy="380" r="18" class="unauth"/>
  <text x="400" y="385" class="label">{4}</text>
  <circle cx="500" cy="380" r="18" class="unauth"/>
  <text x="500" y="385" class="label">{5}</text>

  <!-- Level 2: pairs (unauthorized) -->
  <circle cx="80" cy="300" r="15" class="unauth"/>
  <text x="80" y="304" class="label" style="font-size:9px">{1,2}</text>
  <circle cx="160" cy="300" r="15" class="unauth"/>
  <text x="160" y="304" class="label" style="font-size:9px">{1,3}</text>
  <circle cx="240" cy="300" r="15" class="unauth"/>
  <text x="240" y="304" class="label" style="font-size:9px">{1,4}</text>
  <circle cx="300" cy="300" r="15" class="unauth"/>
  <text x="300" y="304" class="label" style="font-size:9px">{2,3}</text>
  <circle cx="360" cy="300" r="15" class="unauth"/>
  <text x="360" y="304" class="label" style="font-size:9px">{2,4}</text>
  <circle cx="440" cy="300" r="15" class="unauth"/>
  <text x="440" y="304" class="label" style="font-size:9px">{3,4}</text>

  <!-- Level 3: triples (MINIMAL authorized) -->
  <circle cx="100" cy="200" r="18" class="minimal"/>
  <text x="100" y="205" class="label" style="font-size:9px">{1,2,3}</text>
  <circle cx="190" cy="200" r="18" class="minimal"/>
  <text x="190" y="205" class="label" style="font-size:9px">{1,2,4}</text>
  <circle cx="280" cy="200" r="18" class="minimal"/>
  <text x="280" y="205" class="label" style="font-size:9px">{1,3,4}</text>
  <circle cx="370" cy="200" r="18" class="minimal"/>
  <text x="370" y="205" class="label" style="font-size:9px">{2,3,4}</text>
  <circle cx="460" cy="200" r="18" class="minimal"/>
  <text x="460" y="205" class="label" style="font-size:9px">{1,2,5}</text>

  <!-- Level 4: quadruples (authorized) -->
  <circle cx="150" cy="120" r="18" class="auth"/>
  <text x="150" y="125" class="label" style="font-size:8px">{1,2,3,4}</text>
  <circle cx="270" cy="120" r="18" class="auth"/>
  <text x="270" y="125" class="label" style="font-size:8px">{1,2,3,5}</text>
  <circle cx="390" cy="120" r="18" class="auth"/>
  <text x="390" y="125" class="label" style="font-size:8px">{1,3,4,5}</text>

  <!-- Level 5: full set -->
  <circle cx="300" cy="60" r="20" class="auth"/>
  <text x="300" y="65" class="label" style="font-size:8px">{1..5}</text>

  <!-- Legend -->
  <rect x="20" y="40" width="16" height="16" rx="8" class="unauth"/>
  <text x="42" y="53" class="legend">Unauthorized</text>
  <rect x="20" y="62" width="16" height="16" rx="8" class="minimal"/>
  <text x="42" y="75" class="legend">Minimal Authorized (Closure Bases)</text>
  <rect x="20" y="84" width="16" height="16" rx="8" class="auth"/>
  <text x="42" y="97" class="legend">Authorized (Superset of Minimal)</text>

  <!-- Threshold line -->
  <line x1="30" y1="250" x2="570" y2="250" stroke="#3498db" stroke-width="2" stroke-dasharray="8,4"/>
  <text x="555" y="245" class="legend" style="fill: #3498db; font-weight: bold;">t = 3</text>
</svg>'''
    return svg


def generate_closure_basis_svg():
    """Generate SVG showing closure basis concept."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" width="500" height="350" viewBox="0 0 500 350">
  <style>
    .set { fill: #ecf0f1; stroke: #2c3e50; stroke-width: 2; }
    .closure { fill: #dfe6e9; stroke: #2c3e50; stroke-width: 2; stroke-dasharray: 6,3; }
    .point { fill: #e74c3c; stroke: #c0392b; stroke-width: 2; }
    .gen-point { fill: #2ecc71; stroke: #27ae60; stroke-width: 2; }
    .title { font-family: sans-serif; font-size: 14px; text-anchor: middle; fill: #2c3e50; font-weight: bold; }
    .text { font-family: sans-serif; font-size: 11px; fill: #2c3e50; }
    .eq { font-family: serif; font-size: 16px; fill: #2c3e50; font-style: italic; }
  </style>

  <text x="250" y="25" class="title">Minimal Authorized Set = Closure Basis</text>

  <!-- Left: basis B = {a, b, c} -->
  <text x="130" y="55" class="text" style="text-anchor: middle; font-weight: bold;">Basis B = {a, b, c}</text>
  <ellipse cx="130" cy="180" rx="100" ry="120" class="closure"/>
  <text x="130" y="310" class="text" style="text-anchor: middle;">cl(B) = C (closed set)</text>

  <circle cx="90" cy="150" r="10" class="gen-point"/>
  <text x="90" y="135" class="text" style="text-anchor: middle;">a</text>
  <circle cx="160" cy="140" r="10" class="gen-point"/>
  <text x="160" y="125" class="text" style="text-anchor: middle;">b</text>
  <circle cx="120" cy="200" r="10" class="gen-point"/>
  <text x="120" y="225" class="text" style="text-anchor: middle;">c</text>

  <!-- Generated elements -->
  <circle cx="130" cy="170" r="6" class="point"/>
  <circle cx="100" cy="220" r="6" class="point"/>
  <circle cx="155" cy="190" r="6" class="point"/>
  <circle cx="110" cy="250" r="6" class="point"/>
  <circle cx="150" cy="240" r="6" class="point"/>

  <!-- Right: removing one element -->
  <text x="370" y="55" class="text" style="text-anchor: middle; font-weight: bold;">Remove c → {a, b}</text>
  <ellipse cx="370" cy="160" rx="70" ry="80" class="closure" style="fill: #fadbd8;"/>
  <text x="370" y="260" class="text" style="text-anchor: middle; fill: #e74c3c;">cl({a,b}) ⊊ C</text>
  <text x="370" y="280" class="text" style="text-anchor: middle; fill: #e74c3c;">cap drops below t!</text>

  <circle cx="340" cy="140" r="10" class="gen-point"/>
  <text x="340" y="125" class="text" style="text-anchor: middle;">a</text>
  <circle cx="395" cy="135" r="10" class="gen-point"/>
  <text x="395" y="120" class="text" style="text-anchor: middle;">b</text>
  <circle cx="365" cy="170" r="6" class="point"/>
  <circle cx="380" cy="190" r="6" class="point"/>

  <!-- Arrow -->
  <line x1="240" y1="180" x2="280" y2="180" stroke="#7f8c8d" stroke-width="2" marker-end="url(#arrow)"/>
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="10" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 0 L 10 5 L 0 10 z" fill="#7f8c8d"/>
    </marker>
  </defs>
</svg>'''
    return svg


def generate_matplotlib_chart():
    """Generate capacity vs coalition size chart as base64 PNG."""
    if not HAS_MPL:
        return None

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Capacity profile for 3-out-of-5
    ax = axes[0]
    n, k = 5, 3
    sizes = list(range(n + 1))
    avg_caps = []
    for s in sizes:
        if s == 0:
            avg_caps.append(0)
        else:
            caps = []
            for combo in itertools.combinations(range(1, n + 1), s):
                caps.append(min(s, k))
            avg_caps.append(np.mean(caps))

    colors = ['#e74c3c' if c < k else '#2ecc71' for c in avg_caps]
    bars = ax.bar(sizes, avg_caps, color=colors, edgecolor='#2c3e50', linewidth=1.5)
    ax.axhline(y=k, color='#3498db', linestyle='--', linewidth=2, label=f'Threshold t={k}')
    ax.set_xlabel('Coalition Size', fontsize=12)
    ax.set_ylabel('Capacity cap(cl(A))', fontsize=12)
    ax.set_title('3-out-of-5 Threshold Scheme', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xticks(sizes)

    # Right: Number of minimal authorized sets for k-out-of-n
    ax = axes[1]
    ns = range(3, 10)
    for k in [2, 3, 4]:
        counts = []
        valid_ns = []
        for n in ns:
            if k <= n:
                from math import comb
                counts.append(comb(n, k))
                valid_ns.append(n)
        ax.plot(valid_ns, counts, 'o-', label=f'k={k}', linewidth=2, markersize=6)

    ax.set_xlabel('Number of Participants n', fontsize=12)
    ax.set_ylabel('# Minimal Authorized Sets', fontsize=12)
    ax.set_title('Minimal Authorized Set Count', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xticks(list(ns))

    plt.tight_layout()

    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    plt.close()
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


if __name__ == "__main__":
    # Save SVGs
    with open("access_structure.svg", "w") as f:
        f.write(generate_access_structure_svg())
    print("Generated access_structure.svg")

    with open("closure_basis.svg", "w") as f:
        f.write(generate_closure_basis_svg())
    print("Generated closure_basis.svg")

    # Generate matplotlib chart
    chart = generate_matplotlib_chart()
    if chart:
        print(f"Generated matplotlib chart (base64, {len(chart)} chars)")
    else:
        print("matplotlib not available, skipping chart")
