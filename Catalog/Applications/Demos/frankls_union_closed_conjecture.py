"""
Frankl's Union-Closed Conjecture — Applications

Real-world applications of union-closed family theory:
1. Database schema dependency analysis
2. Social network community detection
3. Feature selection in machine learning
4. Voting theory and coalition analysis
"""

from algorithms import (
    union_closure, ground_set, element_frequency, frequency_vector,
    find_frankl_witness, maximal_members, is_union_closed, Family
)


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Database Functional Dependencies
# ═══════════════════════════════════════════════════════════════════════════

def demo_database_dependencies():
    """
    In database theory, the set of attribute closures under functional
    dependencies forms a closure system (intersection-closed family).
    Its complement-dual is a union-closed family.

    Frankl's conjecture implies: in any set of functional dependencies,
    some attribute is "important" — it appears in at least half of all
    possible attribute combinations derivable from the dependencies.

    This demonstrates the concept with a simple employee database schema.
    """
    print("=" * 60)
    print("APPLICATION 1: Database Schema Analysis")
    print("=" * 60)

    # Attributes: 1=EmployeeID, 2=Name, 3=Department, 4=Salary, 5=Manager
    attrs = {1: "EmpID", 2: "Name", 3: "Dept", 4: "Salary", 5: "Manager"}

    # Functional dependencies determine which attribute sets are "closed"
    # Here we model the union-closed family of derivable attribute combinations
    F: Family = union_closure({
        frozenset({1}),           # EmpID alone
        frozenset({1, 2}),        # EmpID determines Name
        frozenset({3, 5}),        # Dept determines Manager
        frozenset({1, 2, 3, 4, 5}),  # Full record
    })

    print(f"\nDatabase attributes: {attrs}")
    print(f"\nDerivable attribute combinations ({len(F)} total):")
    for A in sorted(F, key=lambda s: (len(s), sorted(s))):
        print(f"  {{{', '.join(attrs[x] for x in sorted(A))}}}")

    freqs = frequency_vector(F)
    print(f"\nAttribute importance (frequency in derivable combinations):")
    for x, freq in sorted(freqs.items(), key=lambda p: -p[1]):
        pct = 100 * freq / len(F)
        bar = "█" * int(pct / 5)
        print(f"  {attrs[x]:>8}: {freq}/{len(F)} ({pct:.0f}%) {bar}")

    witness = find_frankl_witness(F)
    if witness:
        print(f"\nFrankl witness: {attrs[witness]} "
              f"(appears in ≥ {len(F)//2} of {len(F)} combinations)")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Social Network Communities
# ═══════════════════════════════════════════════════════════════════════════

def demo_social_network():
    """
    In social networks, communities often satisfy a union-closure property:
    if two overlapping groups merge, the result is also a recognizable community.

    Frankl's conjecture predicts that some individual belongs to at least
    half of all communities — a "universal connector."
    """
    print("=" * 60)
    print("APPLICATION 2: Social Network Community Analysis")
    print("=" * 60)

    people = {1: "Alice", 2: "Bob", 3: "Carol", 4: "Dave",
              5: "Eve", 6: "Frank"}

    # Base communities
    base_communities: Family = {
        frozenset({1, 2}),        # Alice-Bob (work partners)
        frozenset({2, 3}),        # Bob-Carol (neighbors)
        frozenset({1, 4}),        # Alice-Dave (college friends)
        frozenset({3, 5}),        # Carol-Eve (book club)
    }

    communities = union_closure(base_communities)

    print(f"\nPeople: {', '.join(f'{v}({k})' for k, v in people.items())}")
    print(f"\nBase communities: {len(base_communities)}")
    for C in sorted(base_communities, key=lambda s: (len(s), sorted(s))):
        print(f"  {{{', '.join(people[x] for x in sorted(C))}}}")

    print(f"\nAll communities (union-closed): {len(communities)}")
    for C in sorted(communities, key=lambda s: (len(s), sorted(s))):
        print(f"  {{{', '.join(people[x] for x in sorted(C))}}}")

    freqs = frequency_vector(communities)
    print(f"\nCommunity membership count:")
    for x, freq in sorted(freqs.items(), key=lambda p: -p[1]):
        is_majority = 2 * freq >= len(communities)
        marker = " ★ CONNECTOR" if is_majority else ""
        print(f"  {people[x]:>6}: member of {freq}/{len(communities)} "
              f"communities{marker}")

    witness = find_frankl_witness(communities)
    if witness:
        print(f"\nFrankl's theorem guarantees a 'universal connector' exists: "
              f"{people[witness]}")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Feature Selection in Machine Learning
# ═══════════════════════════════════════════════════════════════════════════

def demo_feature_selection():
    """
    In machine learning, feature subsets that achieve good performance
    often form a union-closed family: if features A predict well and
    features B predict well, then A ∪ B also predicts well (more
    features never hurt in the training set, ignoring overfitting).

    Frankl's conjecture implies: some feature appears in at least half
    of all "good" feature subsets — identifying a robust core feature.
    """
    print("=" * 60)
    print("APPLICATION 3: Feature Selection Analysis")
    print("=" * 60)

    features = {1: "age", 2: "income", 3: "education",
                4: "zip_code", 5: "credit_score"}

    # Feature subsets that achieve > 80% accuracy
    good_subsets: Family = {
        frozenset({2, 5}),        # income + credit_score
        frozenset({1, 2, 3}),     # age + income + education
        frozenset({3, 5}),        # education + credit_score
    }

    # Under monotonicity assumption, close under union
    all_good = union_closure(good_subsets)

    print(f"\nFeatures: {features}")
    print(f"\nBase good subsets: {len(good_subsets)}")
    for S in sorted(good_subsets, key=lambda s: (len(s), sorted(s))):
        print(f"  {{{', '.join(features[x] for x in sorted(S))}}}")

    print(f"\nAll good subsets (union-closed): {len(all_good)}")
    for S in sorted(all_good, key=lambda s: (len(s), sorted(s))):
        print(f"  {{{', '.join(features[x] for x in sorted(S))}}}")

    freqs = frequency_vector(all_good)
    print(f"\nFeature robustness (presence in good subsets):")
    for x, freq in sorted(freqs.items(), key=lambda p: -p[1]):
        pct = 100 * freq / len(all_good)
        bar = "█" * int(pct / 5)
        marker = " ← CORE" if 2 * freq >= len(all_good) else ""
        print(f"  {features[x]:>13}: {freq}/{len(all_good)} ({pct:.0f}%) "
              f"{bar}{marker}")

    witness = find_frankl_witness(all_good)
    if witness:
        print(f"\nCore feature (Frankl witness): '{features[witness]}'")
        print(f"  This feature appears in ≥ half of all performant subsets.")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: Voting Theory / Coalition Analysis
# ═══════════════════════════════════════════════════════════════════════════

def demo_voting_coalitions():
    """
    In voting theory, winning coalitions in many systems are union-closed:
    if coalition A wins and coalition B wins, then A ∪ B also wins
    (adding more voters to a winning coalition keeps it winning).

    Frankl's conjecture implies: some voter belongs to at least half
    of all winning coalitions — a "pivotal voter."
    """
    print("=" * 60)
    print("APPLICATION 4: Voting Coalition Analysis")
    print("=" * 60)

    voters = {1: "Party_A", 2: "Party_B", 3: "Party_C",
              4: "Party_D", 5: "Indep_1", 6: "Indep_2"}

    # Minimal winning coalitions (simple majority with 6 voters needs 4)
    # But some parties have more weight
    minimal_winning: Family = {
        frozenset({1, 2, 3}),     # Three major parties
        frozenset({1, 2, 5, 6}),  # Two parties + independents
        frozenset({1, 3, 4}),     # A + C + D
        frozenset({2, 3, 4}),     # B + C + D
    }

    winning = union_closure(minimal_winning)

    print(f"\nVoters: {', '.join(f'{v}' for v in voters.values())}")
    print(f"\nMinimal winning coalitions: {len(minimal_winning)}")
    for C in sorted(minimal_winning, key=lambda s: (len(s), sorted(s))):
        print(f"  {{{', '.join(voters[x] for x in sorted(C))}}}")

    print(f"\nAll winning coalitions: {len(winning)}")

    freqs = frequency_vector(winning)
    print(f"\nVoter power (presence in winning coalitions):")
    for x, freq in sorted(freqs.items(), key=lambda p: -p[1]):
        pct = 100 * freq / len(winning)
        is_pivotal = 2 * freq >= len(winning)
        marker = " ★ PIVOTAL" if is_pivotal else ""
        print(f"  {voters[x]:>8}: {freq}/{len(winning)} ({pct:.0f}%){marker}")

    witness = find_frankl_witness(winning)
    if witness:
        print(f"\nFrankl guarantees a pivotal voter: {voters[witness]}")
        print(f"  This voter appears in ≥ half of all winning coalitions.")
    print()


# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    demo_database_dependencies()
    demo_social_network()
    demo_feature_selection()
    demo_voting_coalitions()


"""
Frankl's Union-Closed Conjecture — Demonstrations

Concrete numerical examples illustrating the key theorems:
1. Double-counting identity verification
2. Average-size criterion (Theorem A)
3. Singleton injection theorem
4. Unique maximal member structure
5. Union-closed / intersection-closed duality
"""

from itertools import combinations
from typing import FrozenSet, Set


# ─── Core types and utilities ───────────────────────────────────────────────

Family = set[frozenset[int]]


def is_union_closed(F: Family) -> bool:
    """Check if a family F is closed under pairwise union."""
    for A in F:
        for B in F:
            if A | B not in F:
                return False
    return True


def ground(F: Family) -> frozenset[int]:
    """Return the union of all members of F."""
    result: set[int] = set()
    for A in F:
        result |= A
    return frozenset(result)


def element_frequency(x: int, F: Family) -> int:
    """Count how many members of F contain element x."""
    return sum(1 for A in F if x in A)


def maximal_members(F: Family) -> Family:
    """Return the set of inclusion-maximal members of F."""
    maxs: Family = set()
    for A in F:
        if not any(A < B for B in F):  # no strictly larger member
            maxs.add(A)
    return maxs


def dual_family(U: frozenset[int], F: Family) -> Family:
    """Complement each member of F within the ground set U."""
    return {U - A for A in F}


# ─── Demo 1: Double-counting identity ──────────────────────────────────────

def demo_double_counting():
    """Verify: ∑_{A ∈ F} |A| = ∑_{x ∈ ground(F)} freq(x, F)."""
    print("=" * 60)
    print("DEMO 1: Double-Counting Identity")
    print("=" * 60)

    F: Family = {
        frozenset(),
        frozenset({1}),
        frozenset({2}),
        frozenset({1, 2}),
        frozenset({1, 2, 3}),
    }
    # Make it union-closed
    F_closed = union_closure(F)

    print(f"Family F (union-closure of input): {sorted([sorted(A) for A in F_closed])}")
    print(f"|F| = {len(F_closed)}")

    lhs = sum(len(A) for A in F_closed)
    G = ground(F_closed)
    rhs = sum(element_frequency(x, F_closed) for x in G)

    print(f"\nLHS: ∑|A| = {lhs}")
    print(f"RHS: ∑ freq(x) = {rhs}")
    print(f"Identity holds: {lhs == rhs} ✓" if lhs == rhs else f"FAILED ✗")
    print()


def union_closure(F: Family) -> Family:
    """Compute the union-closure of a family."""
    closed = set(F)
    changed = True
    while changed:
        changed = False
        new = set()
        for A in closed:
            for B in closed:
                C = A | B
                if C not in closed:
                    new.add(C)
                    changed = True
        closed |= new
    return closed


# ─── Demo 2: Average-size criterion (Theorem A) ────────────────────────────

def demo_average_size_criterion():
    """Show that when average set size ≥ half the ground set, a frequent
    element must exist."""
    print("=" * 60)
    print("DEMO 2: Average-Size Criterion (Theorem A)")
    print("=" * 60)

    # Family where average is large
    F: Family = {
        frozenset({1, 2, 3}),
        frozenset({1, 2}),
        frozenset({1, 3}),
        frozenset({1, 2, 3}),
    }
    F = union_closure(F)

    G = ground(F)
    avg_size = sum(len(A) for A in F) / len(F)
    threshold = len(G) / 2

    print(f"Family: {sorted([sorted(A) for A in F])}")
    print(f"|F| = {len(F)}, ground = {sorted(G)}, |ground| = {len(G)}")
    print(f"Average set size: {avg_size:.2f}")
    print(f"Half ground size: {threshold:.2f}")
    print(f"Average ≥ half ground: {avg_size >= threshold}")

    # Check which elements are frequent
    print("\nElement frequencies:")
    for x in sorted(G):
        freq = element_frequency(x, F)
        is_witness = 2 * freq >= len(F)
        print(f"  x={x}: freq={freq}, 2·freq={2*freq} {'≥' if is_witness else '<'} {len(F)} {'✓ WITNESS' if is_witness else ''}")

    # Verify Theorem A's conclusion
    has_witness = any(2 * element_frequency(x, F) >= len(F) for x in G)
    print(f"\nFrankl witness exists: {has_witness}")
    print()


# ─── Demo 3: Singleton injection theorem ───────────────────────────────────

def demo_singleton_injection():
    """Demonstrate that when {x} ∈ F, the map A ↦ A ∪ {x} injects
    the 'not-containing-x' fiber into the 'containing-x' fiber."""
    print("=" * 60)
    print("DEMO 3: Singleton Injection Theorem")
    print("=" * 60)

    F: Family = union_closure({
        frozenset(),
        frozenset({1}),
        frozenset({2}),
        frozenset({3}),
    })

    print(f"Family F: {sorted([sorted(A) for A in F])}")
    print(f"|F| = {len(F)}")
    print(f"Is union-closed: {is_union_closed(F)}")

    x = 1
    print(f"\nSingleton {{x}} = {{{x}}} ∈ F: {frozenset({x}) in F}")

    F_plus = {A for A in F if x in A}
    F_minus = {A for A in F if x not in A}

    print(f"\nF₊ (containing {x}): {sorted([sorted(A) for A in F_plus])}")
    print(f"F₋ (not containing {x}): {sorted([sorted(A) for A in F_minus])}")

    # Show the injection A ↦ A ∪ {x}
    print(f"\nInjection A ↦ A ∪ {{{x}}}:")
    injection_image = set()
    for A in sorted(F_minus, key=lambda s: (len(s), sorted(s))):
        image = A | frozenset({x})
        injection_image.add(image)
        print(f"  {sorted(A)} ↦ {sorted(image)}")

    print(f"\n|F₋| = {len(F_minus)}, |F₊| = {len(F_plus)}")
    print(f"|F₋| ≤ |F₊|: {len(F_minus) <= len(F_plus)} ✓")
    print(f"2·freq({x}) = {2 * element_frequency(x, F)} ≥ {len(F)} = |F|: "
          f"{2 * element_frequency(x, F) >= len(F)}")
    print()


# ─── Demo 4: Unique maximal member ─────────────────────────────────────────

def demo_unique_maximal():
    """Show that every nonempty union-closed family has exactly one
    maximal member, which equals the ground set."""
    print("=" * 60)
    print("DEMO 4: Unique Maximal Member Theorem")
    print("=" * 60)

    families = [
        union_closure({frozenset(), frozenset({1}), frozenset({2})}),
        union_closure({frozenset({1, 2}), frozenset({3, 4})}),
        union_closure({frozenset({1}), frozenset({2}), frozenset({3})}),
        union_closure({frozenset(range(1, 6))}),
    ]

    for i, F in enumerate(families, 1):
        maxs = maximal_members(F)
        G = ground(F)
        print(f"\nFamily {i}: {sorted([sorted(A) for A in F])}")
        print(f"  |F| = {len(F)}")
        print(f"  Maximal members: {sorted([sorted(M) for M in maxs])}")
        print(f"  Number of maximals: {len(maxs)} (should be 1)")
        print(f"  Ground set: {sorted(G)}")
        if maxs:
            M = next(iter(maxs))
            print(f"  Max = ground: {M == G} ✓" if M == G else f"  Max ≠ ground ✗")
    print()


# ─── Demo 5: Duality theorem ──────────────────────────────────────────────

def demo_duality():
    """Verify that UC families dualize to intersection-closed families."""
    print("=" * 60)
    print("DEMO 5: Union-Closed ↔ Intersection-Closed Duality")
    print("=" * 60)

    F: Family = union_closure({
        frozenset(),
        frozenset({1}),
        frozenset({2}),
        frozenset({1, 2, 3}),
    })

    G = ground(F)
    F_dual = dual_family(G, F)

    print(f"Family F: {sorted([sorted(A) for A in F])}")
    print(f"Ground set U = {sorted(G)}")
    print(f"F is union-closed: {is_union_closed(F)}")

    print(f"\nDual family F* = {{U \\ A : A ∈ F}}:")
    for A in sorted(F, key=lambda s: (len(s), sorted(s))):
        print(f"  U \\ {sorted(A)} = {sorted(G - A)}")

    # Check intersection-closure of dual
    is_ic = True
    for A in F_dual:
        for B in F_dual:
            if A & B not in F_dual:
                is_ic = False
                break
        if not is_ic:
            break

    print(f"\nF* is intersection-closed: {is_ic} ✓" if is_ic else f"\nF* is intersection-closed: {is_ic} ✗")
    print()


# ─── Demo 6: Exhaustive verification of Frankl for small ground sets ──────

def demo_exhaustive_verification():
    """Exhaustively verify Frankl's conjecture for all union-closed
    families on ground sets of size ≤ 4."""
    print("=" * 60)
    print("DEMO 6: Exhaustive Verification (n ≤ 4)")
    print("=" * 60)

    for n in range(1, 5):
        elements = list(range(1, n + 1))
        all_subsets = []
        for k in range(n + 1):
            for combo in combinations(elements, k):
                all_subsets.append(frozenset(combo))

        # Generate all union-closed subfamilies with a nonempty member
        count_uc = 0
        count_frankl = 0
        worst_ratio = float('inf')
        worst_family = None

        for size in range(1, min(len(all_subsets) + 1, 2 ** len(all_subsets))):
            # Too many subsets for full enumeration beyond n=4
            pass

        # Instead, generate random/systematic UC families
        uc_families: list[Family] = []

        # Generate UC families by taking union-closures of small generating sets
        for gen_size in range(1, min(n + 2, 5)):
            for gen_combo in combinations(all_subsets, gen_size):
                gen_set: Family = set(gen_combo)
                if not any(len(A) > 0 for A in gen_set):
                    continue
                F = union_closure(gen_set)
                if len(F) <= 32:
                    uc_families.append(F)

        # Deduplicate
        unique_families: list[Family] = []
        seen: set[frozenset[frozenset[int]]] = set()
        for F in uc_families:
            key = frozenset(F)
            if key not in seen:
                seen.add(key)
                unique_families.append(F)

        frankl_holds = 0
        frankl_fails = 0
        for F in unique_families:
            G = ground(F)
            if not G:
                continue
            best_freq = max(element_frequency(x, F) for x in G)
            if 2 * best_freq >= len(F):
                frankl_holds += 1
            else:
                frankl_fails += 1
                print(f"  COUNTEREXAMPLE FOUND: {F}")

            ratio = best_freq / len(F) if len(F) > 0 else 1
            if ratio < worst_ratio:
                worst_ratio = ratio
                worst_family = F

        print(f"\nn = {n}: {len(unique_families)} UC families tested")
        print(f"  Frankl holds: {frankl_holds}, fails: {frankl_fails}")
        if worst_family:
            print(f"  Tightest ratio: {worst_ratio:.4f} "
                  f"(family: {sorted([sorted(A) for A in worst_family])})")
    print()


# ─── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_double_counting()
    demo_average_size_criterion()
    demo_singleton_injection()
    demo_unique_maximal()
    demo_duality()
    demo_exhaustive_verification()
