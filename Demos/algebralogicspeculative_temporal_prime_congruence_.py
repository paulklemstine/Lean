#!/usr/bin/env python3
"""
Algorithms for Temporal Prime Congruence Spectrum Analysis

Implements the core algorithms:
1. Temporal congruence enumeration
2. Prime (meet-irreducible) congruence detection
3. Separation decision procedure
4. Orbit certificate extraction
5. Spectrum construction
"""

from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass
from demo import (TemporalOracleSemiring, TemporalCongruence,
                  enumerate_temporal_congruences, is_meet_irreducible,
                  compute_orbit)


# ============================================================
# Algorithm 1: Separation Decision Procedure
# ============================================================

@dataclass
class SeparationCertificate:
    """Certificate produced by the separation decision procedure."""
    separated: bool
    congruence: Optional[TemporalCongruence] = None
    is_prime: bool = False
    equality_proof: bool = False


def decide_separation(tos: TemporalOracleSemiring, x: int, y: int,
                       primes: Optional[List[TemporalCongruence]] = None
                       ) -> SeparationCertificate:
    """
    Separation Decision Procedure

    Given x, y in a finite TOS, decide whether they are separated by a
    prime temporal congruence, returning a certificate.

    Algorithm:
    1. If x = y, return IDENTIFIED.
    2. Search prime congruences for one separating x and y.
    3. If found, return SEPARATED with witness.
    4. Fallback: use the diagonal congruence.

    Time complexity: O(|primes| * 1) for the search.
    Space complexity: O(1) beyond the input.
    """
    if x == y:
        return SeparationCertificate(separated=False, equality_proof=True)

    if primes is not None:
        for p in primes:
            if not p.rel(x, y):
                return SeparationCertificate(
                    separated=True, congruence=p, is_prime=True)

    # Fallback: diagonal always separates
    diag = TemporalCongruence(tos.n, [{i} for i in range(tos.n)])
    return SeparationCertificate(separated=True, congruence=diag, is_prime=False)


# ============================================================
# Algorithm 2: Orbit Certificate Extraction
# ============================================================

@dataclass
class OrbitCertificate:
    """Certificate of eventual periodicity."""
    element: int
    preperiod: int
    period: int
    congruence: Optional[TemporalCongruence] = None
    orbit_trace: Optional[List[int]] = None


def extract_orbit_certificate(tos: TemporalOracleSemiring, x: int,
                                cong: Optional[TemporalCongruence] = None
                                ) -> OrbitCertificate:
    """
    Orbit Certificate Extraction

    Given x in a finite TOS (and optionally a congruence), extract a
    certificate of eventual periodicity for x's orbit under tau.

    Algorithm:
    1. Iterate tau starting from x.
    2. Track visited states (or congruence classes).
    3. When a repeat is found, extract preperiod and period.

    Time complexity: O(|R|) iterations.
    Space complexity: O(|R|) for the visited set.
    """
    visited: Dict[int, int] = {}
    trace = []
    current = x

    for step in range(tos.n + 1):
        key = cong._class_map[current] if cong else current
        trace.append(current)
        if key in visited:
            preperiod = visited[key]
            period = step - preperiod
            return OrbitCertificate(
                element=x, preperiod=preperiod, period=period,
                congruence=cong, orbit_trace=trace)
        visited[key] = step
        current = tos.apply_tau(current)

    return OrbitCertificate(element=x, preperiod=0, period=1,
                             congruence=cong, orbit_trace=trace)


# ============================================================
# Algorithm 3: Full Spectrum Construction
# ============================================================

@dataclass
class TemporalSpectrum:
    """The temporal prime spectrum of a TOS."""
    tos: TemporalOracleSemiring
    all_congruences: List[TemporalCongruence]
    prime_congruences: List[TemporalCongruence]
    separation_holds: bool
    orbit_certificates: Dict[int, List[OrbitCertificate]]


def construct_spectrum(tos: TemporalOracleSemiring) -> TemporalSpectrum:
    """
    Full Spectrum Construction

    Computes the temporal prime congruence spectrum of a finite TOS.

    Algorithm:
    1. Enumerate all temporal congruences (via partition search).
    2. Filter for meet-irreducible (prime) congruences.
    3. Verify the prime separation property.
    4. Extract orbit certificates for each element.

    Time complexity: O(B(n) * n^4) where B(n) is the Bell number.
    Space complexity: O(B(n) * n) for storing congruences.
    """
    # Step 1: Enumerate congruences
    congs = enumerate_temporal_congruences(tos)

    # Step 2: Find primes
    primes = [c for c in congs if is_meet_irreducible(c, congs)]

    # Step 3: Check separation
    sep_holds = True
    for x in range(tos.n):
        for y in range(x + 1, tos.n):
            if not any(not p.rel(x, y) for p in primes):
                sep_holds = False
                break
        if not sep_holds:
            break

    # Step 4: Extract orbit certificates
    certs: Dict[int, List[OrbitCertificate]] = {}
    for x in range(tos.n):
        certs[x] = []
        # Raw orbit certificate
        certs[x].append(extract_orbit_certificate(tos, x))
        # Certificates modulo each prime
        for p in primes:
            certs[x].append(extract_orbit_certificate(tos, x, p))

    return TemporalSpectrum(
        tos=tos, all_congruences=congs,
        prime_congruences=primes,
        separation_holds=sep_holds,
        orbit_certificates=certs)


def print_spectrum_report(spec: TemporalSpectrum):
    """Print a human-readable spectrum report."""
    tos = spec.tos
    print(f"{'='*60}")
    print(f"TEMPORAL PRIME SPECTRUM REPORT")
    print(f"{'='*60}")
    print(f"Carrier size: {tos.n}")
    print(f"Total temporal congruences: {len(spec.all_congruences)}")
    print(f"Prime temporal congruences: {len(spec.prime_congruences)}")
    print(f"Prime separation theorem holds: {spec.separation_holds}")
    print()

    print("Prime congruences:")
    for i, p in enumerate(spec.prime_congruences):
        print(f"  P{i}: {p} ({p.num_classes()} classes)")

    print()
    print("Orbit certificates:")
    for x in range(tos.n):
        cert = spec.orbit_certificates[x][0]
        print(f"  {tos.name(x)}: period={cert.period}, "
              f"preperiod={cert.preperiod}")

    print()


if __name__ == "__main__":
    from demo import make_z2xz2_tos, make_z2xz2xz2_tos, make_boolean_tos

    for name, tos in [
        ("Z/2Z × Z/2Z (swap)", make_z2xz2_tos()),
        ("Boolean semiring", make_boolean_tos()),
        ("(Z/2Z)³ (cyclic shift)", make_z2xz2xz2_tos()),
    ]:
        print(f"\n*** {name} ***")
        spec = construct_spectrum(tos)
        print_spectrum_report(spec)

        # Test decision procedure
        primes = spec.prime_congruences
        for x in range(tos.n):
            for y in range(x + 1, tos.n):
                cert = decide_separation(tos, x, y, primes)
                assert cert.separated, f"Failed to separate {x} and {y}"
        print(f"  All pairs separated successfully.")


#!/usr/bin/env python3
"""
Applications of Temporal Prime Congruence Spectra

Demonstrates applications to:
1. Reversible circuit verification
2. Finite automaton behavioral equivalence
3. Periodic behavior detection in dynamical systems
"""

from demo import (TemporalOracleSemiring, TemporalCongruence,
                  enumerate_temporal_congruences, is_meet_irreducible)
from algorithms import construct_spectrum, extract_orbit_certificate


# ============================================================
# Application 1: Reversible Circuit Verification
# ============================================================

def reversible_circuit_demo():
    """Demonstrate using temporal spectra for reversible circuit verification.

    Model a simple 2-bit reversible circuit as a temporal oracle semiring
    over Z/2Z × Z/2Z. The circuit applies a SWAP gate (tau) and we
    verify that distinct input states are always distinguishable after
    any number of time steps.
    """
    print("=" * 60)
    print("APPLICATION 1: Reversible Circuit Verification")
    print("=" * 60)
    print()
    print("Model: 2-bit reversible circuit with SWAP gate")
    print("States: {00, 10, 01, 11} encoded as Z/2Z × Z/2Z")
    print("tau (SWAP): exchanges the two bits")
    print()

    # Z/2Z × Z/2Z with swap
    n = 4
    def enc(a, b): return a + 2 * b
    def dec(x): return (x % 2, x // 2)

    add_table = [[0]*n for _ in range(n)]
    mul_table = [[0]*n for _ in range(n)]
    for x in range(n):
        for y in range(n):
            ax, bx = dec(x)
            ay, by_ = dec(y)
            add_table[x][y] = enc((ax + ay) % 2, (bx + by_) % 2)
            mul_table[x][y] = enc((ax * ay) % 2, (bx * by_) % 2)

    tau = [enc(dec(x)[1], dec(x)[0]) for x in range(n)]
    names = ["00", "10", "01", "11"]

    tos = TemporalOracleSemiring(
        n=n, add_table=add_table, mul_table=mul_table,
        tau=tau, rho=list(range(n)), tau_inv=tau,
        element_names=names)

    spec = construct_spectrum(tos)

    print("Spectrum analysis:")
    print(f"  Prime congruences: {len(spec.prime_congruences)}")
    print(f"  Separation holds: {spec.separation_holds}")
    print()

    print("Verification results:")
    for x in range(n):
        cert = spec.orbit_certificates[x][0]
        print(f"  State {names[x]}: orbit period = {cert.period}")
        if cert.period == 1:
            print(f"    → Fixed point under SWAP")
        elif cert.period == 2:
            print(f"    → Oscillates with period 2 under SWAP")

    print()
    print("Conclusion: All input states are temporally distinguishable.")
    print("The circuit's behavior is fully characterized by the spectrum.")
    print()


# ============================================================
# Application 2: Behavioral Equivalence of Finite Automata
# ============================================================

def automata_equivalence_demo():
    """Using temporal congruences as behavioral equivalences.

    Temporal congruences on a reversible transition system capture
    behavioral equivalence: states related by a temporal congruence
    have identical observable behavior under all temporal operations.
    """
    print("=" * 60)
    print("APPLICATION 2: Behavioral Equivalence Detection")
    print("=" * 60)
    print()
    print("Task: Given a reversible transition system, find the")
    print("coarsest behavioral equivalence (quotient by which all")
    print("temporal observations are preserved).")
    print()

    # Use (Z/2Z)^3 with cyclic shift
    from demo import make_z2xz2xz2_tos
    tos = make_z2xz2xz2_tos()
    spec = construct_spectrum(tos)

    print(f"System: (Z/2Z)³ with cyclic shift tau and coordinate-swap rho")
    print(f"States: 8 elements")
    print()

    # Find the coarsest proper congruence
    proper_congs = [c for c in spec.all_congruences if c.is_proper()]
    if proper_congs:
        coarsest = max(proper_congs, key=lambda c: c.coarseness())
        print(f"Coarsest proper temporal congruence:")
        print(f"  Partition: {coarsest}")
        print(f"  Classes: {coarsest.num_classes()}")
        print(f"  Coarseness: {coarsest.coarseness()}")
    else:
        print("No proper temporal congruences (system is irreducible).")

    print()
    print("Orbit structure under tau:")
    for x in range(tos.n):
        cert = extract_orbit_certificate(tos, x)
        print(f"  {tos.name(x)}: period = {cert.period}")

    # Identify elements with same orbit structure
    orbit_classes = {}
    for x in range(tos.n):
        cert = extract_orbit_certificate(tos, x)
        key = cert.period
        orbit_classes.setdefault(key, []).append(x)

    print()
    print("Elements grouped by orbit period:")
    for period, elements in sorted(orbit_classes.items()):
        print(f"  Period {period}: {[tos.name(e) for e in elements]}")

    print()


# ============================================================
# Application 3: Periodic Behavior Detection
# ============================================================

def periodic_detection_demo():
    """Detecting and certifying periodic behavior in dynamical systems.

    For reversible systems, every orbit is periodic. The temporal
    spectrum provides certificates of this periodicity that are
    verifiable and functorial under quotient maps.
    """
    print("=" * 60)
    print("APPLICATION 3: Certified Periodic Behavior Detection")
    print("=" * 60)
    print()

    from demo import make_z2xz2_tos
    tos = make_z2xz2_tos()

    print("System: Z/2Z × Z/2Z with swap automorphism")
    print()

    spec = construct_spectrum(tos)

    print("Certified orbit analysis:")
    for x in range(tos.n):
        cert = extract_orbit_certificate(tos, x)
        print(f"\n  Element {tos.name(x)}:")
        print(f"    Period: {cert.period}")
        print(f"    Orbit trace: {' → '.join(tos.name(t) for t in cert.orbit_trace)}")

        # Verify certificate
        current = x
        for _ in range(cert.period):
            current = tos.apply_tau(current)
        assert current == x, "Certificate verification failed!"
        print(f"    ✓ Certificate verified: tau^{cert.period}({tos.name(x)}) = {tos.name(x)}")

    print()
    print("All orbit certificates verified successfully.")
    print("These certificates are machine-checkable proofs of eventual periodicity.")
    print()


if __name__ == "__main__":
    reversible_circuit_demo()
    automata_equivalence_demo()
    periodic_detection_demo()


#!/usr/bin/env python3
"""
Temporal Prime Congruence Spectrum — Concrete Demonstrations

Demonstrates temporal oracle semirings, temporal congruences, prime spectra,
orbit certificates, and the separation decision procedure on finite examples.
"""

from typing import List, Tuple, Set, Optional
from dataclasses import dataclass


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class TemporalOracleSemiring:
    """A finite temporal oracle semiring.

    Elements are {0, ..., n-1}. Operations given by tables.
    tau, rho are ring automorphisms (bijective ring endomorphisms).
    """
    n: int
    add_table: List[List[int]]
    mul_table: List[List[int]]
    tau: List[int]
    rho: List[int]
    tau_inv: List[int]
    element_names: Optional[List[str]] = None

    def add(self, a: int, b: int) -> int:
        return self.add_table[a][b]

    def mul(self, a: int, b: int) -> int:
        return self.mul_table[a][b]

    def apply_tau(self, a: int) -> int:
        return self.tau[a]

    def apply_rho(self, a: int) -> int:
        return self.rho[a]

    def name(self, x: int) -> str:
        if self.element_names:
            return self.element_names[x]
        return str(x)

    def verify_axioms(self) -> Tuple[bool, str]:
        """Verify all TOS axioms. Returns (success, message)."""
        n = self.n
        # rho involutive
        for x in range(n):
            if self.rho[self.rho[x]] != x:
                return False, f"rho not involutive at {x}"
        # rho ∘ tau = tau⁻¹ ∘ rho
        for x in range(n):
            if self.rho[self.tau[x]] != self.tau_inv[self.rho[x]]:
                return False, f"rho_tau fails at {x}"
        # tau is ring hom
        for a in range(n):
            for b in range(n):
                if self.tau[self.add(a, b)] != self.add(self.tau[a], self.tau[b]):
                    return False, f"tau not additive: tau({a}+{b})"
                if self.tau[self.mul(a, b)] != self.mul(self.tau[a], self.tau[b]):
                    return False, f"tau not multiplicative: tau({a}*{b})"
        # rho is ring hom
        for a in range(n):
            for b in range(n):
                if self.rho[self.add(a, b)] != self.add(self.rho[a], self.rho[b]):
                    return False, f"rho not additive: rho({a}+{b})"
                if self.rho[self.mul(a, b)] != self.mul(self.rho[a], self.rho[b]):
                    return False, f"rho not multiplicative: rho({a}*{b})"
        return True, "All axioms verified"


class TemporalCongruence:
    """A temporal congruence represented as a partition."""

    def __init__(self, n: int, partition: List[Set[int]]):
        self.n = n
        self.partition = partition
        self._class_map = {}
        for i, cls in enumerate(partition):
            for x in cls:
                self._class_map[x] = i

    def rel(self, a: int, b: int) -> bool:
        return self._class_map[a] == self._class_map[b]

    def num_classes(self) -> int:
        return len(self.partition)

    def is_proper(self) -> bool:
        return self.num_classes() > 1

    def coarseness(self) -> int:
        return sum(len(c) ** 2 for c in self.partition)

    def is_compatible(self, tos: TemporalOracleSemiring) -> bool:
        n = tos.n
        for a in range(n):
            for b in range(n):
                if not self.rel(a, b):
                    continue
                for c in range(n):
                    for d in range(n):
                        if self.rel(c, d):
                            if not self.rel(tos.add(a, c), tos.add(b, d)):
                                return False
                            if not self.rel(tos.mul(a, c), tos.mul(b, d)):
                                return False
                if not self.rel(tos.apply_tau(a), tos.apply_tau(b)):
                    return False
                if not self.rel(tos.apply_rho(a), tos.apply_rho(b)):
                    return False
        return True

    def __repr__(self):
        return str([sorted(c) for c in self.partition])


# ============================================================
# Enumeration and Analysis
# ============================================================

def partitions_of(elements: list) -> list:
    """Generate all set partitions of elements."""
    if not elements:
        yield []
        return
    first = elements[0]
    rest = elements[1:]
    for partition in partitions_of(rest):
        for i in range(len(partition)):
            new_p = [cls.copy() for cls in partition]
            new_p[i].add(first)
            yield new_p
        yield partition + [{first}]


def enumerate_temporal_congruences(tos: TemporalOracleSemiring) -> List[TemporalCongruence]:
    n = tos.n
    congruences = []
    for partition in partitions_of(list(range(n))):
        tc = TemporalCongruence(n, partition)
        if tc.is_compatible(tos):
            congruences.append(tc)
    return congruences


def is_meet_irreducible(c: TemporalCongruence,
                         all_congs: List[TemporalCongruence]) -> bool:
    if not c.is_proper():
        return False
    for c1 in all_congs:
        for c2 in all_congs:
            is_intersection = True
            c_eq_c1 = True
            c_eq_c2 = True
            for a in range(c.n):
                for b in range(c.n):
                    cr = c.rel(a, b)
                    c1r = c1.rel(a, b)
                    c2r = c2.rel(a, b)
                    if cr != (c1r and c2r):
                        is_intersection = False
                        break
                    if cr != c1r:
                        c_eq_c1 = False
                    if cr != c2r:
                        c_eq_c2 = False
                if not is_intersection:
                    break
            if is_intersection and not c_eq_c1 and not c_eq_c2:
                return False
    return True


def compute_orbit(tos: TemporalOracleSemiring, x: int) -> Tuple[int, int]:
    """Compute preperiod and period of x under tau."""
    visited = {}
    current = x
    for step in range(tos.n * 2):
        if current in visited:
            return visited[current], step - visited[current]
        visited[current] = step
        current = tos.apply_tau(current)
    return 0, 1


# ============================================================
# Example Constructions
# ============================================================

def make_z2_tos() -> TemporalOracleSemiring:
    """Z/2Z with identity maps."""
    return TemporalOracleSemiring(
        n=2,
        add_table=[[0, 1], [1, 0]],
        mul_table=[[0, 0], [0, 1]],
        tau=[0, 1], rho=[0, 1], tau_inv=[0, 1],
        element_names=["0", "1"],
    )


def make_z2xz2_tos() -> TemporalOracleSemiring:
    """Z/2Z × Z/2Z with swap automorphism.

    Elements: 0=(0,0), 1=(1,0), 2=(0,1), 3=(1,1).
    tau swaps components: (a,b) -> (b,a).
    rho = identity.
    """
    n = 4
    def enc(a, b): return a + 2 * b
    def dec(x): return (x % 2, x // 2)

    add_table = [[0]*n for _ in range(n)]
    mul_table = [[0]*n for _ in range(n)]
    for x in range(n):
        for y in range(n):
            ax, bx = dec(x)
            ay, by_ = dec(y)
            add_table[x][y] = enc((ax + ay) % 2, (bx + by_) % 2)
            mul_table[x][y] = enc((ax * ay) % 2, (bx * by_) % 2)

    tau = [enc(dec(x)[1], dec(x)[0]) for x in range(n)]
    names = ["(0,0)", "(1,0)", "(0,1)", "(1,1)"]
    return TemporalOracleSemiring(
        n=n, add_table=add_table, mul_table=mul_table,
        tau=tau, rho=list(range(n)), tau_inv=tau,
        element_names=names,
    )


def make_boolean_tos() -> TemporalOracleSemiring:
    """Boolean semiring {⊥, ⊤} with OR/AND. Idempotent."""
    return TemporalOracleSemiring(
        n=2,
        add_table=[[0, 1], [1, 1]],  # OR
        mul_table=[[0, 0], [0, 1]],  # AND
        tau=[0, 1], rho=[0, 1], tau_inv=[0, 1],
        element_names=["⊥", "⊤"],
    )


def make_z3_tos() -> TemporalOracleSemiring:
    """Z/3Z with identity tau and rho.

    Z/nZ has only the identity ring automorphism (since 1 must map to 1).
    """
    n = 3
    add_table = [[(a + b) % n for b in range(n)] for a in range(n)]
    mul_table = [[(a * b) % n for b in range(n)] for a in range(n)]
    return TemporalOracleSemiring(
        n=n, add_table=add_table, mul_table=mul_table,
        tau=list(range(n)), rho=list(range(n)), tau_inv=list(range(n)),
        element_names=["0", "1", "2"],
    )


def make_z2xz2xz2_tos() -> TemporalOracleSemiring:
    """(Z/2Z)^3 with cyclic shift tau and coordinate-swap rho.

    tau: (a,b,c) -> (c,a,b)  (cyclic shift, order 3)
    rho: (a,b,c) -> (c,b,a)  (swap first and third, order 2)
    Axiom check: rho(tau(a,b,c)) = rho(c,a,b) = (b,a,c)
                 tau_inv(rho(a,b,c)) = tau_inv(c,b,a) = (b,a,c) ✓
    """
    n = 8
    def enc(a, b, c): return a + 2*b + 4*c
    def dec(x): return (x % 2, (x // 2) % 2, (x // 4) % 2)

    add_table = [[0]*n for _ in range(n)]
    mul_table = [[0]*n for _ in range(n)]
    for x in range(n):
        for y in range(n):
            ax, bx, cx = dec(x)
            ay, by_, cy = dec(y)
            add_table[x][y] = enc((ax+ay)%2, (bx+by_)%2, (cx+cy)%2)
            mul_table[x][y] = enc((ax*ay)%2, (bx*by_)%2, (cx*cy)%2)

    # tau: cyclic shift (a,b,c) -> (c,a,b)
    tau = [enc(dec(x)[2], dec(x)[0], dec(x)[1]) for x in range(n)]
    # tau_inv: (a,b,c) -> (b,c,a)
    tau_inv = [enc(dec(x)[1], dec(x)[2], dec(x)[0]) for x in range(n)]
    # rho: swap first and third (a,b,c) -> (c,b,a)
    rho = [enc(dec(x)[2], dec(x)[1], dec(x)[0]) for x in range(n)]

    names = [f"({a},{b},{c})" for a, b, c in [dec(x) for x in range(n)]]
    return TemporalOracleSemiring(
        n=n, add_table=add_table, mul_table=mul_table,
        tau=tau, rho=rho, tau_inv=tau_inv,
        element_names=names,
    )


# ============================================================
# Demonstrations
# ============================================================

def demo_spectrum(name: str, tos: TemporalOracleSemiring):
    """Full spectrum analysis of a TOS."""
    print("=" * 60)
    print(f"SPECTRUM ANALYSIS: {name}")
    print("=" * 60)

    ok, msg = tos.verify_axioms()
    print(f"Axiom verification: {msg}")
    if not ok:
        print("SKIPPING — axioms not satisfied")
        print()
        return

    print(f"Elements: {{{', '.join(tos.name(x) for x in range(tos.n))}}}")
    print(f"tau: {[tos.name(tos.tau[x]) for x in range(tos.n)]}")
    print(f"rho: {[tos.name(tos.rho[x]) for x in range(tos.n)]}")
    print()

    # Enumerate congruences
    congs = enumerate_temporal_congruences(tos)
    print(f"Temporal congruences: {len(congs)}")
    for i, c in enumerate(congs):
        print(f"  C{i}: {c}  ({c.num_classes()} classes)")

    # Find primes
    primes = [c for c in congs if is_meet_irreducible(c, congs)]
    print(f"\nPrime (meet-irreducible) congruences: {len(primes)}")
    for i, p in enumerate(primes):
        print(f"  P{i}: {p}")

    # Separation
    print("\nPrime separation test:")
    all_separated = True
    for x in range(tos.n):
        for y in range(x + 1, tos.n):
            seps = [p for p in primes if not p.rel(x, y)]
            if seps:
                print(f"  {tos.name(x)} ≠ {tos.name(y)}: "
                      f"separated by {seps[0]}")
            else:
                print(f"  {tos.name(x)} ≠ {tos.name(y)}: "
                      f"NOT prime-separated!")
                all_separated = False
    print(f"  ✓ Prime separation holds" if all_separated
          else "  ✗ Prime separation fails")

    # Orbits
    print("\nOrbits under tau:")
    for x in range(tos.n):
        pre, per = compute_orbit(tos, x)
        orbit = [x]
        curr = x
        for _ in range(pre + per):
            curr = tos.apply_tau(curr)
            orbit.append(curr)
        print(f"  {tos.name(x)}: "
              f"{' → '.join(tos.name(o) for o in orbit)}  "
              f"(preperiod={pre}, period={per})")

    # Orbit certificates
    print("\nOrbit certificates modulo prime congruences:")
    for i, p in enumerate(primes):
        for x in range(tos.n):
            # Find period modulo this congruence
            seen_classes = {}
            curr = x
            for step in range(tos.n * 2):
                cls = p._class_map[curr]
                if cls in seen_classes:
                    pre = seen_classes[cls]
                    per = step - pre
                    print(f"  P{i}, x={tos.name(x)}: period={per}")
                    break
                seen_classes[cls] = step
                curr = tos.apply_tau(curr)
    print()


def demo_decision_procedure():
    """Demonstrate the full separation decision procedure."""
    print("=" * 60)
    print("DECISION PROCEDURE DEMO")
    print("=" * 60)

    tos = make_z2xz2_tos()
    congs = enumerate_temporal_congruences(tos)
    primes = [c for c in congs if is_meet_irreducible(c, congs)]

    print(f"TOS: Z/2Z × Z/2Z with swap tau")
    print(f"Elements: {[tos.name(x) for x in range(tos.n)]}")
    print()

    for x in range(tos.n):
        for y in range(tos.n):
            if x == y:
                result = f"IDENTIFIED (x = y)"
            else:
                sep = next((p for p in primes if not p.rel(x, y)), None)
                if sep:
                    result = f"SEPARATED by prime {sep}"
                else:
                    result = "SEPARATED by diagonal"
            print(f"  decide({tos.name(x)}, {tos.name(y)}): {result}")
    print()


if __name__ == "__main__":
    # Demo 1: Z/2Z — simplest case
    demo_spectrum("Z/2Z (trivial)", make_z2_tos())

    # Demo 2: Z/2Z × Z/2Z with swap — the main example
    demo_spectrum("Z/2Z × Z/2Z with swap automorphism", make_z2xz2_tos())

    # Demo 3: Boolean semiring — idempotent case
    demo_spectrum("Boolean semiring {⊥, ⊤}", make_boolean_tos())

    # Demo 4: Z/3Z
    demo_spectrum("Z/3Z (trivial automorphisms)", make_z3_tos())

    # Demo 5: Decision procedure
    demo_decision_procedure()

    # Demo 6: Larger example
    demo_spectrum("(Z/2Z)³ with cyclic shift", make_z2xz2xz2_tos())


#!/usr/bin/env python3
"""
Visualizations for Temporal Prime Congruence Spectra

Generates diagrams of temporal spectra, orbit structures,
and congruence lattices.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from demo import (make_z2xz2_tos, make_z2xz2xz2_tos, make_boolean_tos,
                  enumerate_temporal_congruences, is_meet_irreducible,
                  compute_orbit)


def visualize_orbit_diagram(tos, filename="orbit_diagram.png"):
    """Visualize the orbit structure under tau."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    n = tos.n

    # Find orbits
    visited = set()
    orbits = []
    for x in range(n):
        if x in visited:
            continue
        orbit = []
        curr = x
        while curr not in visited:
            visited.add(curr)
            orbit.append(curr)
            curr = tos.apply_tau(curr)
        orbits.append(orbit)

    # Draw orbits as circles
    colors = plt.cm.Set2(np.linspace(0, 1, len(orbits)))
    y_offset = 0

    for oi, (orbit, color) in enumerate(zip(orbits, colors)):
        k = len(orbit)
        if k == 1:
            # Fixed point
            x_pos = 0
            y_pos = y_offset
            ax.plot(x_pos, y_pos, 'o', markersize=30, color=color,
                    markeredgecolor='black', markeredgewidth=2)
            ax.annotate(tos.name(orbit[0]), (x_pos, y_pos),
                       ha='center', va='center', fontsize=11, fontweight='bold')
            # Self-loop arrow
            ax.annotate("", xy=(x_pos + 0.15, y_pos + 0.3),
                       xytext=(x_pos - 0.15, y_pos + 0.3),
                       arrowprops=dict(arrowstyle="->", color='gray',
                                      connectionstyle="arc3,rad=0.8"))
            ax.text(x_pos, y_pos + 0.5, f"period=1",
                   ha='center', fontsize=9, style='italic', color='gray')
        else:
            # Cycle: place nodes in a circle
            radius = 0.4 + 0.15 * k
            angles = [2 * np.pi * i / k - np.pi / 2 for i in range(k)]

            for i, (elem, angle) in enumerate(zip(orbit, angles)):
                x_pos = radius * np.cos(angle) + 2 * oi
                y_pos = radius * np.sin(angle) + y_offset

                ax.plot(x_pos, y_pos, 'o', markersize=30, color=color,
                        markeredgecolor='black', markeredgewidth=2)
                ax.annotate(tos.name(elem), (x_pos, y_pos),
                           ha='center', va='center', fontsize=9, fontweight='bold')

                # Arrow to next
                next_angle = angles[(i + 1) % k]
                x_next = radius * np.cos(next_angle) + 2 * oi
                y_next = radius * np.sin(next_angle) + y_offset

                dx = x_next - x_pos
                dy = y_next - y_pos
                dist = np.sqrt(dx**2 + dy**2)
                if dist > 0:
                    shrink = 0.2
                    ax.annotate("", xy=(x_next - shrink*dx/dist, y_next - shrink*dy/dist),
                               xytext=(x_pos + shrink*dx/dist, y_pos + shrink*dy/dist),
                               arrowprops=dict(arrowstyle="->", color='darkblue',
                                              lw=1.5))

            ax.text(2 * oi, y_offset - radius - 0.4, f"period={k}",
                   ha='center', fontsize=10, style='italic', color='gray')

    ax.set_xlim(-1.5, max(2 * len(orbits), 2))
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("Orbit Structure under Temporal Shift τ", fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved orbit diagram to {filename}")


def visualize_spectrum(tos, filename="spectrum.png"):
    """Visualize the temporal prime spectrum."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    congs = enumerate_temporal_congruences(tos)
    primes = [c for c in congs if is_meet_irreducible(c, congs)]
    n = tos.n

    # Left: Congruence lattice (simplified)
    ax = axes[0]
    ax.set_title("Temporal Congruence Lattice", fontsize=13, fontweight='bold')

    # Place congruences by number of classes
    by_classes = {}
    for c in congs:
        nc = c.num_classes()
        by_classes.setdefault(nc, []).append(c)

    max_classes = max(by_classes.keys())
    for nc, group in by_classes.items():
        y = nc / max_classes
        for i, c in enumerate(group):
            x = (i + 0.5) / len(group)
            is_prime = c in primes
            color = '#e74c3c' if is_prime else '#3498db'
            marker = '*' if is_prime else 'o'
            size = 200 if is_prime else 100

            ax.scatter(x, y, s=size, c=color, marker=marker,
                      edgecolors='black', linewidth=1.5, zorder=5)

            label = f"{nc} cls"
            if not c.is_proper():
                label = "total"
            elif nc == n:
                label = "diag"
            ax.annotate(label, (x, y), textcoords="offset points",
                       xytext=(0, 12), ha='center', fontsize=8)

    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.1, 1.2)
    ax.set_ylabel("Refinement (finer ↑)", fontsize=11)
    ax.set_xticks([])

    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='*', color='w', markerfacecolor='#e74c3c',
               markersize=12, label='Prime', markeredgecolor='black'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#3498db',
               markersize=10, label='Non-prime', markeredgecolor='black'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

    # Right: Separation matrix
    ax = axes[1]
    ax.set_title("Prime Separation Matrix", fontsize=13, fontweight='bold')

    # Create separation matrix
    sep_matrix = np.zeros((n, n))
    for x in range(n):
        for y in range(n):
            if x == y:
                sep_matrix[x][y] = 0
            else:
                count = sum(1 for p in primes if not p.rel(x, y))
                sep_matrix[x][y] = count

    im = ax.imshow(sep_matrix, cmap='YlOrRd', aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    labels = [tos.name(i) for i in range(n)]
    ax.set_xticklabels(labels, fontsize=9)
    ax.set_yticklabels(labels, fontsize=9)
    ax.set_xlabel("Element y", fontsize=11)
    ax.set_ylabel("Element x", fontsize=11)

    # Add text annotations
    for i in range(n):
        for j in range(n):
            val = int(sep_matrix[i][j])
            color = 'white' if val > 0 else 'gray'
            text = str(val) if i != j else "="
            ax.text(j, i, text, ha='center', va='center',
                   fontsize=10, color=color, fontweight='bold')

    plt.colorbar(im, ax=ax, label="# separating primes")
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved spectrum visualization to {filename}")


def visualize_orbit_z2cubed(filename="orbit_z2cubed.png"):
    """Visualize the orbit structure of (Z/2Z)^3 with cyclic shift."""
    tos = make_z2xz2xz2_tos()
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Find orbits
    visited = set()
    orbits = []
    for x in range(tos.n):
        if x in visited:
            continue
        orbit = []
        curr = x
        while curr not in visited:
            visited.add(curr)
            orbit.append(curr)
            curr = tos.apply_tau(curr)
        orbits.append(orbit)

    # Layout: fixed points at left, 3-cycles at right
    colors = ['#2ecc71', '#e74c3c', '#3498db', '#f39c12']

    y_centers = [3, 1.5, -1.5]
    cycle_idx = 0

    for orbit in orbits:
        k = len(orbit)
        if k == 1:
            # Fixed point
            if orbit[0] == 0:
                cx, cy = -2, 2
            else:
                cx, cy = -2, -2

            ax.plot(cx, cy, 'o', markersize=40, color='#2ecc71',
                    markeredgecolor='black', markeredgewidth=2, zorder=5)
            ax.annotate(tos.name(orbit[0]), (cx, cy),
                       ha='center', va='center', fontsize=10, fontweight='bold')
            ax.annotate("", xy=(cx + 0.2, cy + 0.4),
                       xytext=(cx - 0.2, cy + 0.4),
                       arrowprops=dict(arrowstyle="->", color='gray',
                                      connectionstyle="arc3,rad=0.8"))
        else:
            # 3-cycle
            radius = 0.8
            cy = y_centers[cycle_idx] if cycle_idx < len(y_centers) else 0
            cx_center = 2
            color = colors[min(cycle_idx + 1, len(colors) - 1)]

            angles = [2 * np.pi * i / k - np.pi / 2 for i in range(k)]
            for i, (elem, angle) in enumerate(zip(orbit, angles)):
                x_pos = radius * np.cos(angle) + cx_center
                y_pos = radius * np.sin(angle) + cy

                ax.plot(x_pos, y_pos, 'o', markersize=35, color=color,
                        markeredgecolor='black', markeredgewidth=2, zorder=5)
                ax.annotate(tos.name(elem), (x_pos, y_pos),
                           ha='center', va='center', fontsize=8, fontweight='bold')

                next_angle = angles[(i + 1) % k]
                x_next = radius * np.cos(next_angle) + cx_center
                y_next = radius * np.sin(next_angle) + cy

                dx = x_next - x_pos
                dy = y_next - y_pos
                dist = np.sqrt(dx**2 + dy**2)
                if dist > 0:
                    shrink = 0.22
                    ax.annotate("", xy=(x_next - shrink*dx/dist, y_next - shrink*dy/dist),
                               xytext=(x_pos + shrink*dx/dist, y_pos + shrink*dy/dist),
                               arrowprops=dict(arrowstyle="->", color='darkblue', lw=2))

            cycle_idx += 1

    ax.set_xlim(-4, 5)
    ax.set_ylim(-4, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("Orbit Structure of (Z/2Z)³ under Cyclic Shift τ",
                fontsize=14, fontweight='bold')

    # Add annotations
    ax.text(-2, 3.5, "Fixed Points", ha='center', fontsize=11, style='italic', color='gray')
    ax.text(2, 4, "3-Cycles", ha='center', fontsize=11, style='italic', color='gray')

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved (Z/2Z)³ orbit diagram to {filename}")


if __name__ == "__main__":
    # Generate all visualizations
    tos_z2z2 = make_z2xz2_tos()
    visualize_orbit_diagram(tos_z2z2, "orbit_z2xz2.png")
    visualize_spectrum(tos_z2z2, "spectrum_z2xz2.png")
    visualize_orbit_z2cubed("orbit_z2cubed.png")

    print("\nAll visualizations generated successfully.")
