#!/usr/bin/env python3
"""
Schnorr Protocol: Core Algorithms

Implements the cryptographic algorithms underlying the Schnorr identification
protocol, witness extraction, HVZK simulation, and Fiat-Shamir transform.

All algorithms operate over Z/qZ for a prime q, modeling a cyclic group
of prime order.
"""

from dataclasses import dataclass
from typing import Optional, Tuple, List, Callable
import hashlib


# ═══════════════════════════════════════════════════════════════════════
# Data Structures
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class GroupParams:
    """Parameters for a prime-order cyclic group.

    Attributes:
        p: The modulus (a safe prime p = 2q + 1)
        q: The prime order of the subgroup
        g: A generator of the order-q subgroup
    """
    p: int
    q: int
    g: int

    def power(self, base: int, exp: int) -> int:
        """Compute base^exp mod p, reducing exp mod q first."""
        return pow(base, exp % self.q, self.p)

    def multiply(self, a: int, b: int) -> int:
        """Multiply two group elements."""
        return (a * b) % self.p

    def inverse(self, a: int) -> int:
        """Compute the multiplicative inverse of a mod p."""
        return pow(a, self.p - 2, self.p)


@dataclass(frozen=True)
class SchnorrKeypair:
    """A Schnorr key pair.

    Attributes:
        secret: The discrete logarithm x (private key)
        public: y = g^x (public key)
    """
    secret: int
    public: int


@dataclass(frozen=True)
class Transcript:
    """A Schnorr protocol transcript (Σ-protocol view).

    Attributes:
        commitment: a = g^r (prover's first message)
        challenge: c (verifier's challenge)
        response: z = r + c·x mod q (prover's response)
    """
    commitment: int
    challenge: int
    response: int


@dataclass(frozen=True)
class FSProof:
    """A non-interactive Fiat-Shamir proof.

    Attributes:
        commitment: a = g^r
        response: z = r + H(y, a)·x mod q
    """
    commitment: int
    response: int


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Key Generation
# ═══════════════════════════════════════════════════════════════════════

def keygen(grp: GroupParams, secret: Optional[int] = None) -> SchnorrKeypair:
    """Generate a Schnorr key pair.

    Time complexity: O(log q) for modular exponentiation.
    Space complexity: O(log p) for storing group elements.

    Args:
        grp: Group parameters
        secret: Optional secret key (random if not provided)

    Returns:
        A SchnorrKeypair with secret x and public y = g^x.

    Example:
        >>> grp = GroupParams(p=23, q=11, g=4)
        >>> kp = keygen(grp, secret=3)
        >>> kp.public == pow(4, 3, 23)
        True
    """
    import random
    if secret is None:
        secret = random.randint(1, grp.q - 1)
    public = grp.power(grp.g, secret)
    return SchnorrKeypair(secret=secret, public=public)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Real Transcript Generation (Prover)
# ═══════════════════════════════════════════════════════════════════════

def real_transcript(grp: GroupParams, x: int, r: int, c: int) -> Transcript:
    """Generate a real Schnorr transcript.

    The honest prover with witness x and randomness r responds to challenge c.

    Time complexity: O(log q) for two modular exponentiations.
    Space complexity: O(log p).

    Correctness guarantee: schnorr_completeness ensures g^z = a · y^c.

    Args:
        grp: Group parameters
        x: Secret key (witness)
        r: Random nonce
        c: Verifier's challenge

    Returns:
        Transcript(a=g^r, c=c, z=(r + c·x) mod q)
    """
    a = grp.power(grp.g, r)
    z = (r + c * x) % grp.q
    return Transcript(commitment=a, challenge=c, response=z)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Simulated Transcript Generation (HVZK Simulator)
# ═══════════════════════════════════════════════════════════════════════

def simulated_transcript(grp: GroupParams, y: int, c: int, z: int) -> Transcript:
    """Generate a simulated Schnorr transcript (HVZK simulator).

    The simulator, given only the public key y (no witness), produces
    transcripts indistinguishable from real ones.

    Computes: a = g^z · y^(-c)

    Time complexity: O(log q) for three modular exponentiations.
    Space complexity: O(log p).

    Correctness guarantee: schnorr_simulator_accepts ensures g^z = a · y^c.
    Distribution guarantee: schnorr_hvzk_transcript_eq + schnorr_hvzk_bijection
    ensure the joint distribution matches real transcripts exactly.

    Args:
        grp: Group parameters
        y: Public key
        c: Challenge (sampled uniformly)
        z: Response (sampled uniformly)

    Returns:
        Transcript(a=g^z·y^(-c), c=c, z=z)
    """
    gz = grp.power(grp.g, z)
    yc_inv = grp.inverse(grp.power(y, c))
    a = grp.multiply(gz, yc_inv)
    return Transcript(commitment=a, challenge=c, response=z)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Schnorr Verification
# ═══════════════════════════════════════════════════════════════════════

def verify(grp: GroupParams, y: int, t: Transcript) -> bool:
    """Verify a Schnorr transcript.

    Checks: g^z == a · y^c

    Time complexity: O(log q) for three modular exponentiations.
    Space complexity: O(log p).

    Args:
        grp: Group parameters
        y: Public key
        t: Transcript to verify

    Returns:
        True if the transcript is accepting.
    """
    lhs = grp.power(grp.g, t.response)
    rhs = grp.multiply(t.commitment, grp.power(y, t.challenge))
    return lhs == rhs


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Witness Extractor (Special Soundness)
# ═══════════════════════════════════════════════════════════════════════

def extract_witness(
    q: int,
    z1: int, z2: int,
    c1: int, c2: int
) -> Optional[int]:
    """Extract the discrete logarithm witness from two forked transcripts.

    Given two accepting transcripts (a, c₁, z₁) and (a, c₂, z₂) with
    the SAME commitment a but DIFFERENT challenges c₁ ≠ c₂, computes:

        w = (z₁ - z₂) · (c₁ - c₂)⁻¹ mod q

    This is the algebraic essence of special soundness: the Schnorr
    verification equation z = r + c·x is an affine function of the
    challenge c with slope x (the witness). Two points on this line
    determine the slope.

    Time complexity: O(log q) for modular inversion.
    Space complexity: O(log q).

    Correctness guarantee: schnorr_special_soundness_extract proves
    y = g^w for the extracted w.

    Args:
        q: Group order (prime)
        z1, z2: Responses from the two transcripts
        c1, c2: Challenges from the two transcripts

    Returns:
        The extracted witness w, or None if c1 == c2.

    Example:
        >>> # If x=5, r=3, c1=2, c2=7 over Z/11Z:
        >>> z1 = (3 + 2*5) % 11  # = 2
        >>> z2 = (3 + 7*5) % 11  # = 5
        >>> extract_witness(11, z1, z2, 2, 7)
        5
    """
    dc = (c1 - c2) % q
    if dc == 0:
        return None
    dc_inv = pow(dc, q - 2, q)  # Fermat's little theorem
    w = ((z1 - z2) * dc_inv) % q
    return w


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 6: Fiat-Shamir Transform
# ═══════════════════════════════════════════════════════════════════════

def fiat_shamir_prove(
    grp: GroupParams,
    y: int,
    x: int,
    r: int,
    hash_fn: Optional[Callable[[int, int], int]] = None
) -> FSProof:
    """Generate a non-interactive Fiat-Shamir proof.

    Replaces the verifier's challenge with H(y, a) where H is a
    hash function (random oracle model).

    Time complexity: O(log q) + O(hash).
    Space complexity: O(log p).

    Args:
        grp: Group parameters
        y: Public key
        x: Secret key
        r: Random nonce
        hash_fn: Hash function (y, a) -> challenge. Uses SHA-256 if None.

    Returns:
        FSProof with commitment and response.
    """
    if hash_fn is None:
        def hash_fn(y_val: int, a_val: int) -> int:
            h = hashlib.sha256(f"{y_val}:{a_val}".encode()).digest()
            return int.from_bytes(h, 'big') % grp.q

    a = grp.power(grp.g, r)
    c = hash_fn(y, a)
    z = (r + c * x) % grp.q
    return FSProof(commitment=a, response=z)


def fiat_shamir_verify(
    grp: GroupParams,
    y: int,
    proof: FSProof,
    hash_fn: Optional[Callable[[int, int], int]] = None
) -> bool:
    """Verify a Fiat-Shamir proof.

    Recomputes the challenge as c = H(y, a) and checks g^z = a · y^c.

    Args:
        grp: Group parameters
        y: Public key
        proof: The FS proof to verify
        hash_fn: Hash function matching the prover's.

    Returns:
        True if the proof verifies.
    """
    if hash_fn is None:
        def hash_fn(y_val: int, a_val: int) -> int:
            h = hashlib.sha256(f"{y_val}:{a_val}".encode()).digest()
            return int.from_bytes(h, 'big') % grp.q

    c = hash_fn(y, proof.commitment)
    t = Transcript(commitment=proof.commitment, challenge=c, response=proof.response)
    return verify(grp, y, t)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 7: Affine Transcript Map
# ═══════════════════════════════════════════════════════════════════════

def transcript_affine_map(x: int, r: int, c: int, q: int) -> int:
    """Compute the affine transcript map: z = r + c·x mod q.

    This is the linear-algebraic interpretation of Schnorr: the response z
    is an affine function of the challenge c, with intercept r and slope x.

    Args:
        x: Witness (slope)
        r: Nonce (intercept)
        c: Challenge (input)
        q: Modulus

    Returns:
        z = r + c·x mod q
    """
    return (r + c * x) % q


def affine_interpolate(
    c1: int, z1: int,
    c2: int, z2: int,
    q: int
) -> Optional[int]:
    """Recover the slope (witness) from two points on a transcript affine line.

    Given (c₁, z₁) and (c₂, z₂) on the line z = r + c·x, computes
    x = (z₁ - z₂)/(c₁ - c₂) mod q.

    This is exactly the schnorrExtractor formula, reinterpreted as
    affine interpolation over the finite field Z/qZ.

    Args:
        c1, z1: First point
        c2, z2: Second point
        q: Modulus

    Returns:
        The slope x, or None if c1 == c2.
    """
    return extract_witness(q, z1, z2, c1, c2)


# ═══════════════════════════════════════════════════════════════════════
# Usage Examples
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Example: Z/23Z with order-11 subgroup
    grp = GroupParams(p=23, q=11, g=4)

    # Key generation
    kp = keygen(grp, secret=5)
    print(f"Key pair: secret={kp.secret}, public={kp.public}")
    print(f"  g^x = {grp.power(grp.g, kp.secret)} = {kp.public}")

    # Real transcript
    t = real_transcript(grp, x=kp.secret, r=3, c=7)
    print(f"\nReal transcript: {t}")
    print(f"  Verifies: {verify(grp, kp.public, t)}")

    # Simulated transcript
    t_sim = simulated_transcript(grp, y=kp.public, c=7, z=5)
    print(f"\nSimulated transcript: {t_sim}")
    print(f"  Verifies: {verify(grp, kp.public, t_sim)}")

    # Extraction
    t1 = real_transcript(grp, x=kp.secret, r=3, c=2)
    t2 = real_transcript(grp, x=kp.secret, r=3, c=7)
    w = extract_witness(grp.q, t1.response, t2.response, t1.challenge, t2.challenge)
    print(f"\nExtraction from forked transcripts:")
    print(f"  Extracted witness: {w}")
    print(f"  True secret: {kp.secret}")
    print(f"  Match: {w == kp.secret}")

    # Fiat-Shamir
    proof = fiat_shamir_prove(grp, kp.public, kp.secret, r=3)
    print(f"\nFiat-Shamir proof: {proof}")
    print(f"  Verifies: {fiat_shamir_verify(grp, kp.public, proof)}")
