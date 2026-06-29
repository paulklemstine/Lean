#!/usr/bin/env python3
"""
applications.py — Real-world applications of nonlinear extraction obstruction theory.

Demonstrates how the fiber-ambiguity results apply to:
1. Protocol design: detecting nonlinear extraction vulnerabilities
2. Symmetry-breaking: augmenting protocols to restore uniqueness
3. Polynomial witness maps of arbitrary degree
4. Comparative analysis across field sizes
"""

import random
from typing import List, Tuple, Dict, Callable
from algorithms import (
    extract_image, enumerate_fiber, classify_extraction,
    fiber_statistics, compute_injective_domain, ExtractionResult
)


def application_1_protocol_vulnerability_scan():
    """
    Application 1: Scan a protocol for extraction vulnerabilities.

    Given a witness map g and a field F_p, determine whether the protocol
    z = t + c * g(w) admits unique extraction or has fiber ambiguity.
    """
    print("=" * 70)
    print("APPLICATION 1: Protocol Vulnerability Scanner")
    print("=" * 70)
    print()

    primes = [5, 7, 11, 13, 17, 19, 23]

    # Test various witness maps
    witness_maps = [
        ("Linear: g(w) = w", lambda w, p: w % p, 1),
        ("Quadratic: g(w) = w²", lambda w, p: pow(w, 2, p), 2),
        ("Cubic: g(w) = w³", lambda w, p: pow(w, 3, p), 3),
        ("Quartic: g(w) = w⁴", lambda w, p: pow(w, 4, p), 4),
        ("Affine-quad: g(w) = w² + w", lambda w, p: (w*w + w) % p, 2),
    ]

    print(f"  {'Witness Map':<30} | {'p':>3} | {'|Image|':>7} | {'MaxFiber':>8} | {'Status':<15}")
    print(f"  {'-'*30}-+-{'-'*3}-+-{'-'*7}-+-{'-'*8}-+-{'-'*15}")

    for name, g_param, deg in witness_maps:
        for p in primes:
            g = lambda w, _p=p, _g=g_param: _g(w, _p)
            stats = fiber_statistics(g, p)
            status = "VULNERABLE" if stats["has_collision"] else "SAFE"
            print(f"  {name:<30} | {p:>3} | {stats['image_size']:>7} | "
                  f"{stats['max_fiber_size']:>8} | {status:<15}")
    print()


def application_2_symmetry_breaking():
    """
    Application 2: Symmetry-breaking by augmenting observables.

    Shows that exposing both g₁(w) = w² and g₂(w) = w³ (or g₂(w) = w)
    can break the ±w ambiguity of the squaring map.
    """
    print("=" * 70)
    print("APPLICATION 2: Symmetry-Breaking via Augmented Observables")
    print("=" * 70)
    print()

    p = 17

    print(f"  Field: F_{p}")
    print()

    # Original protocol: only w²
    print("  --- Single observable: w² ---")
    g1 = lambda w: pow(w, 2, p)

    for w in range(1, (p-1)//2 + 1):
        neg_w = (-w) % p
        print(f"    w={w:>2}: w²={g1(w):>2},  -w={neg_w:>2}: (-w)²={g1(neg_w):>2}  "
              f"{'← COLLISION' if g1(w) == g1(neg_w) and w != neg_w else ''}")
    print()

    # Augmented protocol: w² AND w³
    print("  --- Augmented observables: (w², w³) ---")
    g2 = lambda w: pow(w, 3, p)

    collisions = 0
    for w in range(1, p):
        for v in range(w+1, p):
            if g1(w) == g1(v) and g2(w) == g2(v):
                collisions += 1
                print(f"    COLLISION: w={w}, v={v}: "
                      f"(w²,w³)=({g1(w)},{g2(w)}), (v²,v³)=({g1(v)},{g2(v)})")

    if collisions == 0:
        print("    No collisions! Augmenting with w³ breaks ALL ambiguity. ✓")
    print()

    # Augmented protocol: w² AND linear w
    print("  --- Augmented observables: (w², w) ---")
    print("    Trivially resolves ambiguity: the second observable IS the witness.")
    print("    This is the degenerate case — but it proves the principle.")
    print()


def application_3_degree_analysis():
    """
    Application 3: How extraction ambiguity grows with polynomial degree.

    For g(w) = w^d over F_p, the generic fiber size divides d.
    This creates a degree-dependent extraction barrier.
    """
    print("=" * 70)
    print("APPLICATION 3: Degree-Dependent Extraction Barriers")
    print("=" * 70)
    print()

    p = 23  # Moderate prime

    print(f"  Field: F_{p}")
    print(f"  Witness map: g(w) = w^d")
    print()

    print(f"  {'Degree d':>8} | {'|Image|':>7} | {'AvgFiber':>8} | {'MaxFiber':>8} | "
          f"{'Unique?':>7} | {'Extraction Status':<20}")
    print(f"  {'-'*8}-+-{'-'*7}-+-{'-'*8}-+-{'-'*8}-+-{'-'*7}-+-{'-'*20}")

    for d in range(1, 12):
        g = lambda w, _d=d: pow(w, _d, p)
        stats = fiber_statistics(g, p)

        # Check if extraction is unique for a random witness
        w_test = random.randint(1, p-1)
        u = g(w_test)
        fiber = enumerate_fiber(g, u, p)

        status = "UNIQUE" if not stats["has_collision"] else f"AMBIGUOUS (≤{stats['max_fiber_size']})"

        print(f"  {d:>8} | {stats['image_size']:>7} | "
              f"{stats['avg_fiber_size']:>8.2f} | {stats['max_fiber_size']:>8} | "
              f"{'YES' if not stats['has_collision'] else 'NO':>7} | {status:<20}")

    print()
    print("  Key insight: odd-degree maps over F_p can be injective (e.g., cubing")
    print("  when gcd(3, p-1) = 1), but even-degree maps always have collisions.")
    print()


def application_4_field_size_scaling():
    """
    Application 4: How fiber structure scales with field size.

    For the squaring map, the fiber structure is universal:
    - 0 has fiber {0}
    - Each nonzero QR has fiber {w, -w} of size 2
    - Non-residues have empty fibers
    """
    print("=" * 70)
    print("APPLICATION 4: Field Size Scaling of Quadratic Ambiguity")
    print("=" * 70)
    print()

    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    print(f"  {'Prime p':>7} | {'|F_p|':>5} | {'#QR':>4} | {'#NQR':>5} | "
          f"{'Fiber=1':>7} | {'Fiber=2':>7} | {'Ambig%':>6}")
    print(f"  {'-'*7}-+-{'-'*5}-+-{'-'*4}-+-{'-'*5}-+-{'-'*7}-+-{'-'*7}-+-{'-'*6}")

    for p in primes:
        g = lambda w, _p=p: pow(w, 2, _p)
        stats = fiber_statistics(g, p)
        dist = stats["fiber_size_distribution"]

        n_qr = (p - 1) // 2  # Nonzero quadratic residues
        n_nqr = (p - 1) // 2  # Non-residues

        fiber1 = dist.get(1, 0)
        fiber2 = dist.get(2, 0)
        ambig_pct = 100 * fiber2 / stats["image_size"] if stats["image_size"] > 0 else 0

        print(f"  {p:>7} | {p:>5} | {n_qr:>4} | {n_nqr:>5} | "
              f"{fiber1:>7} | {fiber2:>7} | {ambig_pct:>5.1f}%")

    print()
    print("  As p → ∞, roughly half of all image values have fiber size 2.")
    print("  The ambiguity fraction stabilizes near (p-1)/(p+1) → 100%.")
    print("  Quadratic extraction obstruction is PERSISTENT, not a small-field artifact.")
    print()


def application_5_protocol_design_recommendation():
    """
    Application 5: Concrete protocol design recommendations.

    Based on the obstruction theory, recommend how to design
    nonlinear Σ-protocols that admit unique extraction.
    """
    print("=" * 70)
    print("APPLICATION 5: Protocol Design Recommendations")
    print("=" * 70)
    print()

    p = 17

    print("  PROBLEM: You want a Σ-protocol with witness map g(w) = w².")
    print(f"  Field: F_{p}")
    print()

    print("  OPTION A: Restrict witness domain to injective half")
    domain = list(range(0, (p-1)//2 + 1))
    print(f"    Domain S = {domain}")
    print(f"    Squaring is injective on S: ", end="")
    images = [pow(w, 2, p) for w in domain]
    print("YES ✓" if len(images) == len(set(images)) else "NO ✗")
    print(f"    Extraction is unique for witnesses in S.")
    print()

    print("  OPTION B: Add auxiliary observable h(w) = w³")
    print("    Combined map (w², w³) is injective on F_p* : ", end="")
    combined = [(pow(w, 2, p), pow(w, 3, p)) for w in range(1, p)]
    print("YES ✓" if len(combined) == len(set(combined)) else "NO ✗")
    print("    Requires modified protocol with two response channels.")
    print()

    print("  OPTION C: Use odd-degree witness map")
    # Find degrees where g(w)=w^d is injective
    injective_degrees = []
    for d in range(1, p):
        g = lambda w, _d=d: pow(w, _d, p)
        stats = fiber_statistics(g, p)
        if not stats["has_collision"]:
            injective_degrees.append(d)

    print(f"    Injective power maps w^d for d in {{1,...,{p-1}}}: "
          f"{injective_degrees[:10]}{'...' if len(injective_degrees) > 10 else ''}")
    print(f"    These are exactly the d with gcd(d, p-1) = 1.")
    print()

    print("  RECOMMENDATION: For quadratic witness dependence, use Option A")
    print("  (domain restriction) as it requires no protocol modification,")
    print("  only a verifier-side check that the extracted witness is in S.")
    print()


if __name__ == "__main__":
    random.seed(42)

    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF NONLINEAR EXTRACTION OBSTRUCTION THEORY           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    application_1_protocol_vulnerability_scan()
    application_2_symmetry_breaking()
    application_3_degree_analysis()
    application_4_field_size_scaling()
    application_5_protocol_design_recommendation()


#!/usr/bin/env python3
"""
demo.py — Demonstration of nonlinear Σ-protocol extraction obstructions.

Shows concretely that:
1. In affine (linear) protocols, two transcripts uniquely recover the witness.
2. In quadratic protocols, two (or more) transcripts recover only the image w²,
   leaving an ambiguity between w and -w.
3. No number of transcripts resolves this ambiguity.
4. Restricting to an injective domain (e.g., positive representatives) restores uniqueness.
"""

import random
from typing import List, Tuple, Optional


def mod_inv(a: int, p: int) -> int:
    """Compute modular inverse of a mod p using Fermat's little theorem."""
    return pow(a, p - 2, p)


def affine_extraction_demo(p: int = 17):
    """
    Demonstrate affine (linear) extraction: z = t + c * w mod p.
    Two transcripts with distinct challenges uniquely recover w.
    """
    print("=" * 70)
    print(f"AFFINE (LINEAR) EXTRACTION over F_{p}")
    print("=" * 70)
    print(f"Protocol: z = t + c * w  (mod {p})")
    print()

    # Secret witness
    w = random.randint(1, p - 1)
    # Commitment randomness
    t = random.randint(0, p - 1)

    print(f"  Secret witness:  w = {w}")
    print(f"  Commitment term: t = {t}")
    print()

    # Generate two transcripts with distinct challenges
    c1 = random.randint(0, p - 1)
    c2 = c1
    while c2 == c1:
        c2 = random.randint(0, p - 1)

    z1 = (t + c1 * w) % p
    z2 = (t + c2 * w) % p

    print(f"  Transcript 1: c₁ = {c1}, z₁ = {z1}")
    print(f"  Transcript 2: c₂ = {c2}, z₂ = {z2}")
    print()

    # Extract witness
    w_extracted = ((z1 - z2) * mod_inv((c1 - c2) % p, p)) % p
    print(f"  Extracted:  w = (z₁ - z₂) / (c₁ - c₂) = {w_extracted}")
    print(f"  Correct?    {w_extracted == w}  ✓" if w_extracted == w else f"  INCORRECT! ✗")
    print()

    # Check uniqueness: enumerate all w' that satisfy both equations
    compatible = []
    for w_test in range(p):
        if (t + c1 * w_test) % p == z1 and (t + c2 * w_test) % p == z2:
            compatible.append(w_test)
    print(f"  All compatible witnesses: {compatible}")
    print(f"  Unique? {'YES ✓' if len(compatible) == 1 else 'NO ✗'}")
    print()


def quadratic_extraction_demo(p: int = 17):
    """
    Demonstrate quadratic extraction failure: z = t + c * w² mod p.
    Two transcripts recover only u = w², not w itself.
    """
    print("=" * 70)
    print(f"QUADRATIC (NONLINEAR) EXTRACTION over F_{p}")
    print("=" * 70)
    print(f"Protocol: z = t + c * w²  (mod {p})")
    print()

    # Secret witness (nonzero)
    w = random.randint(1, p - 1)
    w_sq = (w * w) % p
    t = random.randint(0, p - 1)

    print(f"  Secret witness:  w = {w}")
    print(f"  Witness image:   w² = {w_sq}")
    print(f"  Commitment term: t = {t}")
    print()

    # Generate two transcripts
    c1 = random.randint(0, p - 1)
    c2 = c1
    while c2 == c1:
        c2 = random.randint(0, p - 1)

    z1 = (t + c1 * w_sq) % p
    z2 = (t + c2 * w_sq) % p

    print(f"  Transcript 1: c₁ = {c1}, z₁ = {z1}")
    print(f"  Transcript 2: c₂ = {c2}, z₂ = {z2}")
    print()

    # Extract IMAGE (not witness)
    u_extracted = ((z1 - z2) * mod_inv((c1 - c2) % p, p)) % p
    print(f"  Extracted image: u = (z₁ - z₂) / (c₁ - c₂) = {u_extracted}")
    print(f"  Correct image?   {u_extracted == w_sq}  ✓" if u_extracted == w_sq
          else f"  INCORRECT IMAGE! ✗")
    print()

    # Find ALL witnesses compatible with both transcripts
    compatible = []
    for w_test in range(p):
        w_test_sq = (w_test * w_test) % p
        if (t + c1 * w_test_sq) % p == z1 and (t + c2 * w_test_sq) % p == z2:
            compatible.append(w_test)

    print(f"  All compatible witnesses: {compatible}")
    print(f"  Number of compatible witnesses: {len(compatible)}")
    if len(compatible) > 1:
        print(f"  ⚠ AMBIGUITY! Cannot uniquely extract witness from transcripts alone.")
        # Check that they're ±w
        neg_w = (-w) % p
        print(f"  Note: w = {w}, -w = {neg_w} (mod {p})")
        print(f"  Both {w} and {neg_w} satisfy w² = {w_sq}")
    print()


def multi_transcript_demo(p: int = 17, num_transcripts: int = 10):
    """
    Demonstrate that MORE transcripts do NOT resolve the quadratic ambiguity.
    """
    print("=" * 70)
    print(f"MULTI-TRANSCRIPT QUADRATIC EXTRACTION ({num_transcripts} transcripts) over F_{p}")
    print("=" * 70)
    print(f"Protocol: z_i = t + c_i * w²  (mod {p}), i = 1,...,{num_transcripts}")
    print()

    w = random.randint(1, p - 1)
    w_sq = (w * w) % p
    t = random.randint(0, p - 1)

    print(f"  Secret witness: w = {w}, w² = {w_sq}")
    print(f"  Commitment: t = {t}")
    print()

    # Generate many transcripts with distinct challenges
    challenges = random.sample(range(p), min(num_transcripts, p))
    transcripts = [(c, (t + c * w_sq) % p) for c in challenges]

    print(f"  Transcripts (c_i, z_i):")
    for i, (c, z) in enumerate(transcripts):
        print(f"    {i+1}. c = {c}, z = {z}")
    print()

    # Find all witnesses compatible with ALL transcripts
    compatible = []
    for w_test in range(p):
        w_test_sq = (w_test * w_test) % p
        all_ok = all((t + c * w_test_sq) % p == z for c, z in transcripts)
        if all_ok:
            compatible.append(w_test)

    print(f"  Compatible witnesses after {num_transcripts} transcripts: {compatible}")
    print(f"  Number: {len(compatible)}")
    if len(compatible) > 1:
        print(f"  ⚠ Still ambiguous! More transcripts did NOT help.")
        print(f"  The ambiguity w ↔ -w persists regardless of transcript count.")
    print()


def injective_domain_demo(p: int = 17):
    """
    Demonstrate that restricting to an injective domain restores unique extraction.
    """
    print("=" * 70)
    print(f"RESTRICTED-DOMAIN EXTRACTION over F_{p}")
    print("=" * 70)
    print()

    # Define an injective domain: {1, 2, ..., (p-1)/2}
    # On this domain, squaring is injective (one representative per ±w pair)
    half = (p - 1) // 2
    S = list(range(1, half + 1))
    print(f"  Injective domain S = {{1, ..., {half}}} = {S}")
    print(f"  On S, squaring is injective (one representative per ±w pair)")
    print()

    # Verify injectivity
    images = [pow(x, 2, p) for x in S]
    assert len(images) == len(set(images)), "Squaring is not injective on S!"
    print(f"  Images w² for w ∈ S: {images}")
    print(f"  All distinct? YES ✓")
    print()

    # Now do extraction restricted to S
    w = random.choice(S)
    w_sq = pow(w, 2, p)
    t = random.randint(0, p - 1)

    c1 = random.randint(0, p - 1)
    c2 = c1
    while c2 == c1:
        c2 = random.randint(0, p - 1)

    z1 = (t + c1 * w_sq) % p
    z2 = (t + c2 * w_sq) % p

    print(f"  Secret witness: w = {w} (in S)")
    print(f"  Transcripts: c₁={c1}, z₁={z1}; c₂={c2}, z₂={z2}")

    # Extract image
    u = ((z1 - z2) * mod_inv((c1 - c2) % p, p)) % p
    print(f"  Extracted image: u = {u}")

    # Find compatible witnesses IN S
    compatible_in_S = [w_test for w_test in S if pow(w_test, 2, p) == u]
    print(f"  Compatible witnesses in S: {compatible_in_S}")
    print(f"  Unique in S? {'YES ✓' if len(compatible_in_S) == 1 else 'NO ✗'}")
    print()


def fiber_structure_demo(p: int = 17):
    """
    Visualize the fiber structure of the squaring map over F_p.
    """
    print("=" * 70)
    print(f"FIBER STRUCTURE OF SQUARING MAP over F_{p}")
    print("=" * 70)
    print()

    # Compute fibers
    fibers = {}
    for w in range(p):
        img = pow(w, 2, p)
        fibers.setdefault(img, []).append(w)

    print(f"  {'Image u':>10} | {'Fiber g⁻¹(u)':<30} | {'Fiber size':>10}")
    print(f"  {'-'*10}-+-{'-'*30}-+-{'-'*10}")
    for u in sorted(fibers.keys()):
        fiber = fibers[u]
        print(f"  {u:>10} | {str(fiber):<30} | {len(fiber):>10}")

    print()
    print(f"  Quadratic residues (image of squaring): {sorted(fibers.keys())}")
    print(f"  Number of quadratic residues: {len(fibers)}")
    print(f"  Non-zero elements with fiber size 2: "
          f"{sum(1 for u, f in fibers.items() if len(f) == 2)}")
    print(f"  Zero has fiber size: {len(fibers.get(0, []))}")
    print()
    print("  Key insight: every nonzero quadratic residue has EXACTLY 2 preimages")
    print("  (w and -w), making unique extraction impossible without domain restriction.")
    print()


if __name__ == "__main__":
    random.seed(42)

    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  NONLINEAR Σ-PROTOCOL EXTRACTION: DEMONSTRATION                    ║")
    print("║  From Special Soundness to Fiber Ambiguity                         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    p = 17  # Small odd prime for demonstration

    affine_extraction_demo(p)
    quadratic_extraction_demo(p)
    multi_transcript_demo(p, num_transcripts=8)
    fiber_structure_demo(p)
    injective_domain_demo(p)

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
  1. AFFINE protocols: 2 transcripts → unique witness extraction ✓
  2. QUADRATIC protocols: 2 transcripts → image extraction only
     (ambiguity w ↔ -w persists)
  3. MORE transcripts: still only image extraction
     (all transcripts factor through w²)
  4. RESTRICTED DOMAIN: choosing one representative per ±w pair
     restores unique extraction ✓

  The fundamental obstruction is the FIBER STRUCTURE of the witness map.
  Extraction recovers the algebraic image g(w), not the witness w.
  Witness recovery requires injectivity of g on the candidate domain.
""")
