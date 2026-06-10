#!/usr/bin/env python3
"""
applications.py — Real-world applications of the Novelty Certification Framework.

Demonstrates:
1. Theorem library deduplication
2. Conjecture novelty screening
3. AI-generated theorem auditing
4. Diversity-driven theorem generation
"""

import random
import math
from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class Descriptor:
    """Theorem descriptor with 9 features."""
    quant_depth: int = 0
    symbol_count: int = 0
    binder_count: int = 0
    has_eq: bool = False
    has_forall: bool = False
    has_exists: bool = False
    nat_arity: int = 0
    fin_arity: int = 0
    bool_arity: int = 0

    def embed(self) -> list[float]:
        return [
            float(self.quant_depth), float(self.symbol_count),
            float(self.binder_count),
            1.0 if self.has_eq else 0.0,
            1.0 if self.has_forall else 0.0,
            1.0 if self.has_exists else 0.0,
            float(self.nat_arity), float(self.fin_arity),
            float(self.bool_arity),
        ]

    def short_str(self) -> str:
        bools = f"{'E' if self.has_eq else '-'}{'A' if self.has_forall else '-'}{'X' if self.has_exists else '-'}"
        return (f"D(qd={self.quant_depth},sc={self.symbol_count},"
                f"bc={self.binder_count},{bools},"
                f"n={self.nat_arity},f={self.fin_arity},b={self.bool_arity})")


def sup_norm_dist(d1: Descriptor, d2: Descriptor) -> float:
    e1, e2 = d1.embed(), d2.embed()
    return max(abs(a - b) for a, b in zip(e1, e2))


def archive_dist(archive: list[Descriptor], d: Descriptor) -> tuple[float, Optional[int]]:
    if not archive:
        return 0.0, None
    best = float('inf')
    idx = 0
    for i, a in enumerate(archive):
        dist = sup_norm_dist(d, a)
        if dist < best:
            best = dist
            idx = i
    return best, idx


# ─────────────────────────────────────────────────────────────────────
# Application 1: Theorem Library Deduplication
# ─────────────────────────────────────────────────────────────────────
print("=" * 70)
print("APPLICATION 1: Theorem Library Deduplication")
print("=" * 70)

# Simulated theorem library with some "duplicates" (identical descriptors)
library = [
    ("add_comm",       Descriptor(1, 4, 2, True, True, False, 2, 0, 0)),
    ("add_comm'",      Descriptor(1, 4, 2, True, True, False, 2, 0, 0)),  # duplicate!
    ("prime_infinite",  Descriptor(2, 5, 3, True, True, True, 2, 0, 0)),
    ("prime_exists",    Descriptor(2, 5, 3, True, True, True, 2, 0, 0)),  # duplicate!
    ("bool_dec",        Descriptor(0, 2, 0, True, False, False, 0, 0, 1)),
    ("nat_rec",         Descriptor(2, 6, 3, True, True, False, 3, 0, 0)),
    ("fin_bound",       Descriptor(1, 3, 1, True, True, False, 1, 1, 0)),
    ("fin_bound_alt",   Descriptor(1, 3, 1, True, True, False, 1, 1, 0)),  # duplicate!
]

print(f"\nLibrary size: {len(library)}")
print("\nScanning for potential duplicates (distance = 0):")

duplicates_found = []
for i in range(len(library)):
    for j in range(i + 1, len(library)):
        dist = sup_norm_dist(library[i][1], library[j][1])
        if dist == 0:
            duplicates_found.append((library[i][0], library[j][0]))
            print(f"  ⚠ '{library[i][0]}' ↔ '{library[j][0]}': distance = 0 (potential duplicate)")

print(f"\nTotal potential duplicates: {len(duplicates_found)}")
print("(Under injectivity, distance 0 ↔ identical descriptors)")

# Near-duplicates
print("\nNear-duplicates (distance ≤ 1):")
for i in range(len(library)):
    for j in range(i + 1, len(library)):
        dist = sup_norm_dist(library[i][1], library[j][1])
        if 0 < dist <= 1:
            print(f"  ~ '{library[i][0]}' ↔ '{library[j][0]}': distance = {dist}")


# ─────────────────────────────────────────────────────────────────────
# Application 2: Conjecture Novelty Screening
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("APPLICATION 2: Conjecture Novelty Screening")
print("=" * 70)

# Known theorems archive
known_theorems = [d for _, d in library]

# Conjectures to screen
conjectures = [
    ("Goldbach-like",   Descriptor(3, 7, 4, True, True, True, 3, 0, 0)),
    ("Simple identity",  Descriptor(1, 4, 2, True, True, False, 2, 0, 0)),
    ("Exotic Fin",       Descriptor(4, 12, 6, True, True, True, 0, 4, 0)),
    ("Boolean tautology", Descriptor(0, 3, 0, True, False, False, 0, 0, 2)),
]

print(f"\nKnown archive size: {len(known_theorems)}")
print(f"Conjectures to screen: {len(conjectures)}\n")

for name, conj in conjectures:
    dist, nn_idx = archive_dist(known_theorems, conj)
    status = "✅ NOVEL" if dist > 0 else "⚠ POSSIBLY KNOWN"
    nn_name = library[nn_idx][0] if nn_idx is not None else "N/A"
    print(f"  {name:20s}: dist = {dist:.1f}, nearest = '{nn_name}' → {status}")


# ─────────────────────────────────────────────────────────────────────
# Application 3: AI-Generated Theorem Auditing
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("APPLICATION 3: AI-Generated Theorem Auditing")
print("=" * 70)

random.seed(2024)

# Simulate AI generating 20 candidate theorems
ai_candidates = []
for i in range(20):
    # AI sometimes rediscovers known results
    if random.random() < 0.3:
        # Copy a known theorem (rediscovery)
        source = random.choice(known_theorems)
        ai_candidates.append((f"ai_thm_{i}", source, True))
    else:
        # Generate something new
        d = Descriptor(
            random.randint(0, 5), random.randint(1, 15),
            random.randint(0, 8), random.choice([True, False]),
            random.choice([True, False]), random.choice([True, False]),
            random.randint(0, 4), random.randint(0, 3), random.randint(0, 3))
        ai_candidates.append((f"ai_thm_{i}", d, False))

print(f"\nAI generated {len(ai_candidates)} candidate theorems")
print(f"Auditing against archive of {len(known_theorems)} known theorems...\n")

novel_count = 0
rediscovery_count = 0
epsilon = 0.5

for name, desc, was_copied in ai_candidates:
    dist, nn_idx = archive_dist(known_theorems, desc)
    is_novel = dist >= epsilon
    
    if is_novel:
        novel_count += 1
        flag = "✅ Novel"
    else:
        rediscovery_count += 1
        flag = "⚠ Rediscovery" if dist == 0 else "⚠ Near-duplicate"
    
    detection = ""
    if was_copied and not is_novel:
        detection = " [correctly caught]"
    elif was_copied and is_novel:
        detection = " [MISSED - should investigate]"
    
    print(f"  {name}: dist={dist:.1f} → {flag}{detection}")

print(f"\nSummary: {novel_count} novel, {rediscovery_count} flagged")


# ─────────────────────────────────────────────────────────────────────
# Application 4: Diversity-Driven Theorem Generation
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("APPLICATION 4: Diversity-Driven Theorem Generation")
print("=" * 70)

random.seed(999)

def generate_diverse_theorems(archive: list[Descriptor], n: int,
                               n_candidates: int = 100) -> list[Descriptor]:
    """
    Generate n diverse theorems by maximizing minimum archive distance.
    
    For each slot, generate n_candidates random descriptors and select
    the one with maximum archive distance. Then add it to the archive.
    """
    result = []
    current_archive = list(archive)
    
    for _ in range(n):
        best_candidate = None
        best_dist = -1.0
        
        for _ in range(n_candidates):
            candidate = Descriptor(
                random.randint(0, 6), random.randint(1, 20),
                random.randint(0, 10), random.choice([True, False]),
                random.choice([True, False]), random.choice([True, False]),
                random.randint(0, 5), random.randint(0, 5), random.randint(0, 5))
            
            dist, _ = archive_dist(current_archive, candidate)
            if dist > best_dist:
                best_dist = dist
                best_candidate = candidate
        
        if best_candidate is not None:
            result.append((best_candidate, best_dist))
            current_archive.append(best_candidate)
    
    return result

seed_archive = [d for _, d in library[:4]]
print(f"\nSeed archive size: {len(seed_archive)}")
print(f"Generating 8 maximally diverse theorems...\n")

diverse = generate_diverse_theorems(seed_archive, 8)
for i, (desc, dist) in enumerate(diverse):
    print(f"  Generated {i+1}: {desc.short_str()}")
    print(f"           archive distance at generation: {dist:.1f}")

# Verify monotonicity: archive distances of fixed point decrease
print("\n\nVerifying monotonicity (archive distance of a fixed point decreases):")
fixed_point = Descriptor(3, 10, 5, True, True, True, 3, 2, 1)
growing = list(seed_archive)
for i, (desc, _) in enumerate(diverse):
    growing.append(desc)
    dist, _ = archive_dist(growing, fixed_point)
    print(f"  After adding gen_{i+1}: archive_dist(fixed_point) = {dist:.1f}")

print("\n" + "=" * 70)
print("All applications completed successfully!")
print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Concrete demonstrations of the Novelty Certification Framework.

Generates finite theorem descriptor archives and checks novelty certificates,
illustrating all formally verified theorems with numerical examples.
"""

import math
import random
from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class Descriptor:
    """A theorem descriptor capturing 9 syntactic/semantic features."""
    quant_depth: int
    symbol_count: int
    binder_count: int
    has_eq: bool
    has_forall: bool
    has_exists: bool
    nat_arity: int
    fin_arity: int
    bool_arity: int

    def embed(self) -> list[float]:
        """Embed into R^9 (matching the formal definition)."""
        return [
            float(self.quant_depth),
            float(self.symbol_count),
            float(self.binder_count),
            1.0 if self.has_eq else 0.0,
            1.0 if self.has_forall else 0.0,
            1.0 if self.has_exists else 0.0,
            float(self.nat_arity),
            float(self.fin_arity),
            float(self.bool_arity),
        ]


def sup_norm(v: list[float]) -> float:
    """Compute the sup (L∞) norm of a vector."""
    return max(abs(x) for x in v)


def vec_diff(v1: list[float], v2: list[float]) -> list[float]:
    """Compute v1 - v2."""
    return [a - b for a, b in zip(v1, v2)]


def embedding_distance(d1: Descriptor, d2: Descriptor) -> float:
    """Compute ‖embed(d1) - embed(d2)‖ in sup-norm."""
    return sup_norm(vec_diff(d1.embed(), d2.embed()))


def archive_dist(archive: list[Descriptor], d: Descriptor) -> tuple[float, Optional[Descriptor]]:
    """
    Compute the archive distance and nearest neighbor.
    Returns (distance, nearest_neighbor).
    """
    if not archive:
        return 0.0, None
    best_dist = float('inf')
    best_neighbor = None
    for a in archive:
        dist = embedding_distance(d, a)
        if dist < best_dist:
            best_dist = dist
            best_neighbor = a
    return best_dist, best_neighbor


def is_novel(archive: list[Descriptor], d: Descriptor, epsilon: float) -> bool:
    """Check if d is ε-novel relative to the archive."""
    dist, _ = archive_dist(archive, d)
    return epsilon <= dist


def random_descriptor(max_depth=5, max_symbols=20, max_binders=10,
                      max_arity=5) -> Descriptor:
    """Generate a random descriptor."""
    return Descriptor(
        quant_depth=random.randint(0, max_depth),
        symbol_count=random.randint(1, max_symbols),
        binder_count=random.randint(0, max_binders),
        has_eq=random.choice([True, False]),
        has_forall=random.choice([True, False]),
        has_exists=random.choice([True, False]),
        nat_arity=random.randint(0, max_arity),
        fin_arity=random.randint(0, max_arity),
        bool_arity=random.randint(0, max_arity),
    )


# ─────────────────────────────────────────────────────────────────────
# Demo 1: Basic Novelty Certification
# ─────────────────────────────────────────────────────────────────────
print("=" * 70)
print("DEMO 1: Basic Novelty Certification")
print("=" * 70)

# Create some "known theorems" as descriptors
archive = [
    Descriptor(2, 5, 3, True, True, True, 2, 0, 0),   # "∀ n, ∃ p > n, prime p"
    Descriptor(1, 3, 1, True, True, False, 1, 0, 0),   # "∀ n, n + 0 = n"
    Descriptor(1, 4, 2, True, True, False, 2, 0, 0),   # "∀ a b, a + b = b + a"
    Descriptor(0, 2, 0, True, False, False, 0, 0, 1),  # "true = true"
    Descriptor(2, 6, 3, True, True, True, 3, 0, 0),    # "∀ n, ∃ m, n < m ∧ prime m"
]

# A candidate theorem
candidate = Descriptor(3, 8, 4, True, True, True, 1, 2, 0)
print(f"\nCandidate descriptor: {candidate}")
print(f"Candidate embedding: {candidate.embed()}")

dist, nearest = archive_dist(archive, candidate)
print(f"\nArchive distance: {dist}")
print(f"Nearest neighbor: {nearest}")

epsilon = 2.0
novel = is_novel(archive, candidate, epsilon)
print(f"\nIs {epsilon}-novel? {novel}")
print(f"  (Certificate: distance {dist} {'≥' if novel else '<'} threshold {epsilon})")

# Verify pointwise lower bound (novelty_certificate_iff)
print("\nPointwise distances to all archive elements:")
for i, a in enumerate(archive):
    d = embedding_distance(candidate, a)
    print(f"  Archive[{i}]: distance = {d} {'≥' if d >= epsilon else '<'} {epsilon}")

# ─────────────────────────────────────────────────────────────────────
# Demo 2: Embedding Injectivity
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 2: Embedding Injectivity Verification")
print("=" * 70)

# Generate many random descriptors and verify no collisions
random.seed(42)
n_samples = 10000
descriptors = set()
embeddings: dict[tuple, Descriptor] = {}
collisions = 0

for _ in range(n_samples):
    d = random_descriptor()
    emb = tuple(d.embed())
    if emb in embeddings:
        if embeddings[emb] != d:
            collisions += 1
            print(f"  COLLISION: {d} and {embeddings[emb]} have same embedding!")
    else:
        embeddings[emb] = d
    descriptors.add(d)

print(f"\nGenerated {n_samples} random descriptors")
print(f"Unique descriptors: {len(descriptors)}")
print(f"Unique embeddings: {len(embeddings)}")
print(f"Collisions (same embedding, different descriptor): {collisions}")
print("Injectivity confirmed!" if collisions == 0 else "INJECTIVITY VIOLATED!")

# ─────────────────────────────────────────────────────────────────────
# Demo 3: Zero-Distance Characterization
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 3: Zero-Distance ↔ Archive Membership")
print("=" * 70)

# Test archiveDist_eq_zero_iff
member = archive[2]  # Known to be in archive
non_member = Descriptor(4, 10, 5, False, True, True, 3, 1, 2)

dist_member, _ = archive_dist(archive, member)
dist_non_member, nn = archive_dist(archive, non_member)

print(f"\nMember descriptor: {member}")
print(f"  Archive distance: {dist_member}")
print(f"  In archive? {member in archive}")
print(f"  archiveDist = 0 ↔ d ∈ A: {(dist_member == 0) == (member in archive)} ✓")

print(f"\nNon-member descriptor: {non_member}")
print(f"  Archive distance: {dist_non_member}")
print(f"  Nearest neighbor: {nn}")
print(f"  In archive? {non_member in archive}")
print(f"  archiveDist = 0 ↔ d ∈ A: {(dist_non_member == 0) == (non_member in archive)} ✓")

# ─────────────────────────────────────────────────────────────────────
# Demo 4: Monotonicity Under Archive Growth
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 4: Monotonicity Under Archive Growth")
print("=" * 70)

random.seed(123)
test_candidate = Descriptor(3, 7, 4, True, True, False, 2, 1, 1)
growing_archive = []
distances = []

print(f"\nTest candidate: {test_candidate}")
print(f"\nArchive size → Archive distance:")

for i in range(50):
    growing_archive.append(random_descriptor())
    dist, _ = archive_dist(growing_archive, test_candidate)
    distances.append(dist)
    if (i + 1) % 10 == 0:
        print(f"  |A| = {i+1:3d}: archiveDist = {dist:.2f}")

# Verify monotonicity
is_monotone = all(distances[i] >= distances[i+1] - 1e-10 for i in range(len(distances)-1))
print(f"\nMonotonicity verified: {is_monotone} ✓")

# ─────────────────────────────────────────────────────────────────────
# Demo 5: Lipschitz Transfer
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 5: 1-Lipschitz Transfer Inequality")
print("=" * 70)

random.seed(456)
test_archive = [random_descriptor() for _ in range(20)]

print("\nVerifying: archiveDist(A, d₁) - ‖embed(d₁) - embed(d₂)‖ ≤ archiveDist(A, d₂)")
violations = 0

for trial in range(1000):
    d1 = random_descriptor()
    d2 = random_descriptor()
    dist1, _ = archive_dist(test_archive, d1)
    dist2, _ = archive_dist(test_archive, d2)
    emb_dist = embedding_distance(d1, d2)
    
    lhs = dist1 - emb_dist
    if lhs > dist2 + 1e-10:
        violations += 1
        print(f"  VIOLATION at trial {trial}: {lhs:.4f} > {dist2:.4f}")

print(f"\nTrials: 1000, Violations: {violations}")
print("Lipschitz bound verified!" if violations == 0 else "LIPSCHITZ BOUND VIOLATED!")

# ─────────────────────────────────────────────────────────────────────
# Demo 6: Novelty Certificate Equivalence
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 6: Certificate Equivalence (Iff)")
print("=" * 70)

random.seed(789)
cert_archive = [random_descriptor() for _ in range(15)]
cert_candidate = random_descriptor()
epsilon = 3.0

dist_val, nn = archive_dist(cert_archive, cert_candidate)
novel_flag = is_novel(cert_archive, cert_candidate, epsilon)

print(f"\nCandidate: {cert_candidate}")
print(f"Archive size: {len(cert_archive)}")
print(f"Threshold ε = {epsilon}")
print(f"Archive distance = {dist_val}")
print(f"Novel? {novel_flag}")

# Verify equivalence: Novel ↔ ∀ a ∈ A, ε ≤ ‖embed(d) - embed(a)‖
all_far = all(embedding_distance(cert_candidate, a) >= epsilon for a in cert_archive)
print(f"\nAll archive elements at distance ≥ ε? {all_far}")
print(f"Novel ↔ All-far equivalence: {novel_flag == all_far} ✓")

# ─────────────────────────────────────────────────────────────────────
# Demo 7: Witness Realization
# ─────────────────────────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 7: Nearest-Neighbor Witness Realization")
print("=" * 70)

random.seed(101)
witness_archive = [random_descriptor() for _ in range(10)]
witness_candidate = random_descriptor()

dist_val, nearest = archive_dist(witness_archive, witness_candidate)
if nearest is not None:
    witness_dist = embedding_distance(witness_candidate, nearest)
    print(f"\nCandidate: {witness_candidate}")
    print(f"Archive distance: {dist_val}")
    print(f"Nearest neighbor: {nearest}")
    print(f"Distance to nearest: {witness_dist}")
    print(f"Witness realizes infimum: {abs(dist_val - witness_dist) < 1e-10} ✓")

print("\n" + "=" * 70)
print("All demos completed successfully!")
print("=" * 70)
