#!/usr/bin/env python3
"""
Algorithms for Schnorr Zero-Knowledge Proofs

Implements the core cryptographic algorithms with full documentation,
type hints, and complexity analysis.
"""

from typing import Tuple, Optional, List
from dataclasses import dataclass
import hashlib
import secrets


@dataclass
class GroupParams:
    """Parameters for a prime-order cyclic group.
    
    We work in the order-q subgroup of (ℤ/pℤ)* where p = 2q + 1
    is a safe prime. This gives us:
    - A group of known prime order q
    - Efficient modular exponentiation
    - The Decisional Diffie-Hellman assumption holds
    
    Time complexity: O(1) for parameter access
    Space complexity: O(log p) bits
    """
    p: int  # Safe prime modulus
    q: int  # Prime order of subgroup  
    g: int  # Generator of the order-q subgroup


@dataclass  
class KeyPair:
    """A Schnorr key pair.
    
    The secret key x is a random element of ℤ_q.
    The public key y = g^x mod p.
    """
    secret: int  # x ∈ ℤ_q
    public: int   # y = g^x mod p


@dataclass
class Transcript:
    """A Schnorr protocol transcript (a, c, z).
    
    - a: commitment (g^r mod p)
    - c: challenge (random or hash-derived)
    - z: response (r + c*x mod q)
    """
    commitment: int
    challenge: int
    response: int


# ============================================================
# Algorithm 1: Schnorr Key Generation
# ============================================================

def schnorr_keygen(params: GroupParams) -> KeyPair:
    """Generate a Schnorr key pair.
    
    Algorithm:
        1. Sample x ←$ ℤ_q uniformly at random
        2. Compute y = g^x mod p
        3. Return (x, y)
    
    Time: O(log²q · log p) — one modular exponentiation
    Space: O(log p)
    
    Security: The public key y reveals no information about x
    under the Discrete Logarithm assumption.
    """
    x = secrets.randbelow(params.q - 1) + 1  # x ∈ {1, ..., q-1}
    y = pow(params.g, x, params.p)
    return KeyPair(secret=x, public=y)


# ============================================================
# Algorithm 2: Schnorr Interactive Prover
# ============================================================

def schnorr_commit(params: GroupParams) -> Tuple[int, int]:
    """Prover's first move: generate commitment.
    
    Algorithm:
        1. Sample r ←$ ℤ_q uniformly at random
        2. Compute a = g^r mod p
        3. Return (a, r)    [r is kept secret]
    
    Time: O(log²q · log p) — one modular exponentiation
    """
    r = secrets.randbelow(params.q)
    a = pow(params.g, r, params.p)
    return a, r


def schnorr_respond(params: GroupParams, x: int, r: int, c: int) -> int:
    """Prover's second move: compute response to challenge.
    
    Algorithm:
        Given witness x, randomness r, challenge c:
        1. Compute z = r + c·x mod q
        2. Return z
    
    Time: O(log²q) — one modular multiplication and addition
    
    Correctness: g^z = g^(r+cx) = g^r · (g^x)^c = a · y^c ✓
    """
    return (r + c * x) % params.q


# ============================================================
# Algorithm 3: Schnorr Verifier
# ============================================================

def schnorr_verify(params: GroupParams, y: int, t: Transcript) -> bool:
    """Verify a Schnorr proof transcript.
    
    Algorithm:
        Given public key y and transcript (a, c, z):
        1. Compute lhs = g^z mod p
        2. Compute rhs = a · y^c mod p
        3. Accept iff lhs = rhs
    
    Time: O(log²q · log p) — two modular exponentiations
    Space: O(log p)
    
    Soundness: A cheating prover succeeds with probability ≤ 1/q
    for uniformly random challenge c.
    """
    lhs = pow(params.g, t.response, params.p)
    rhs = (t.commitment * pow(y, t.challenge, params.p)) % params.p
    return lhs == rhs


# ============================================================
# Algorithm 4: Special Soundness Extractor
# ============================================================

def schnorr_extract(params: GroupParams, t1: Transcript, t2: Transcript) -> int:
    """Extract the witness from two accepting transcripts.
    
    Algorithm (Special Soundness Extractor):
        Given two accepting transcripts (a, c₁, z₁) and (a, c₂, z₂)
        with same commitment a and c₁ ≠ c₂:
        1. Compute Δz = z₁ - z₂ mod q
        2. Compute Δc = c₁ - c₂ mod q
        3. Compute x = Δz · (Δc)⁻¹ mod q
        4. Return x
    
    Time: O(log²q) — one modular inversion (via extended Euclidean)
    
    Correctness proof:
        From verification: g^z₁ = a · y^c₁ and g^z₂ = a · y^c₂
        Dividing: g^(z₁-z₂) = y^(c₁-c₂)
        So y = g^((z₁-z₂)/(c₁-c₂)) = g^x
        
    This is the proof-of-knowledge extractor for Schnorr.
    """
    assert t1.commitment == t2.commitment, "Commitments must match"
    assert t1.challenge != t2.challenge, "Challenges must differ"
    
    delta_z = (t1.response - t2.response) % params.q
    delta_c = (t1.challenge - t2.challenge) % params.q
    delta_c_inv = pow(delta_c, params.q - 2, params.q)  # Fermat's little theorem
    x = (delta_z * delta_c_inv) % params.q
    return x


# ============================================================
# Algorithm 5: HVZK Simulator
# ============================================================

def schnorr_simulate(params: GroupParams, y: int, 
                     c: Optional[int] = None,
                     z: Optional[int] = None) -> Transcript:
    """HVZK Simulator: produce a valid transcript without the witness.
    
    Algorithm:
        Given public key y (no secret key needed!):
        1. Sample z ←$ ℤ_q and c ←$ ℤ_q uniformly
        2. Compute a = g^z · y^(-c) mod p
        3. Return transcript (a, c, z)
    
    Time: O(log²q · log p) — two modular exponentiations
    
    Zero-Knowledge property:
        The distribution of (a, c, z) from the simulator is identical
        to the distribution from an honest execution with random challenge.
        
        Proof: The map (r, c) ↦ (c, r + c·x) is a bijection on ℤ_q × ℤ_q,
        so the real randomness (r, c) ↔ simulated randomness (c, z=r+cx)
        are in exact 1-to-1 correspondence.
    """
    if c is None:
        c = secrets.randbelow(params.q)
    if z is None:
        z = secrets.randbelow(params.q)
    
    gz = pow(params.g, z, params.p)
    y_neg_c = pow(y, params.q - c, params.p)
    a = (gz * y_neg_c) % params.p
    return Transcript(commitment=a, challenge=c, response=z)


# ============================================================
# Algorithm 6: Fiat-Shamir Non-Interactive Proof
# ============================================================

def fiat_shamir_hash(params: GroupParams, y: int, a: int) -> int:
    """Random oracle H: (y, a) → ℤ_q.
    
    Uses SHA-256 as the hash function, reduced modulo q.
    In the random oracle model, this behaves as a truly random function.
    """
    data = f"{params.p}:{params.g}:{y}:{a}".encode()
    h = hashlib.sha256(data).digest()
    return int.from_bytes(h, 'big') % params.q


def fiat_shamir_prove(params: GroupParams, x: int) -> Tuple[int, Transcript]:
    """Generate a non-interactive Schnorr proof via Fiat-Shamir.
    
    Algorithm:
        1. Sample r ←$ ℤ_q
        2. Compute a = g^r mod p
        3. Compute c = H(y, a)        [hash replaces verifier]
        4. Compute z = r + c·x mod q
        5. Return (y, (a, c, z))
    
    Time: O(log²q · log p) — two modular exponentiations + one hash
    
    Correctness: By Schnorr completeness, the proof always verifies.
    Soundness: In the random oracle model, extracting a witness
    requires the forking lemma (rewinding the adversary with
    different oracle responses at the commitment query).
    """
    y = pow(params.g, x, params.p)
    r = secrets.randbelow(params.q)
    a = pow(params.g, r, params.p)
    c = fiat_shamir_hash(params, y, a)
    z = (r + c * x) % params.q
    return y, Transcript(commitment=a, challenge=c, response=z)


def fiat_shamir_verify(params: GroupParams, y: int, t: Transcript) -> bool:
    """Verify a non-interactive Schnorr proof.
    
    Algorithm:
        1. Recompute c' = H(y, a)
        2. Check c' = c (hash consistency)
        3. Check g^z = a · y^c mod p (Schnorr verification)
        4. Accept iff both checks pass
    
    Time: O(log²q · log p) — two modular exponentiations + one hash
    """
    c_expected = fiat_shamir_hash(params, y, t.commitment)
    if t.challenge != c_expected:
        return False
    return schnorr_verify(params, y, t)


# ============================================================
# Algorithm 7: Forking Extractor
# ============================================================

def forking_extract(params: GroupParams, 
                    t1: Transcript, t2: Transcript,
                    y: int) -> Optional[int]:
    """Forking extractor for Fiat-Shamir Schnorr.
    
    Algorithm:
        Given two accepting transcripts from different oracle instances
        with the same commitment but different challenges:
        1. Verify both transcripts accept
        2. Check commitments match and challenges differ  
        3. Apply special soundness extractor
        4. Verify extracted witness: y =? g^x mod p
        5. Return x if valid
    
    This is the algebraic core of the forking lemma:
    if an adversary can produce accepting FS proofs under two
    different random oracles that agree on all queries except
    at the commitment point, then we can extract the witness.
    
    Time: O(log²q · log p)
    """
    if t1.commitment != t2.commitment:
        return None
    if t1.challenge == t2.challenge:
        return None
    if not schnorr_verify(params, y, t1):
        return None
    if not schnorr_verify(params, y, t2):
        return None
    
    x = schnorr_extract(params, t1, t2)
    
    # Verify the extracted witness
    if pow(params.g, x, params.p) == y:
        return x
    return None


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    from sympy import isprime, nextprime
    import random
    
    print("Schnorr Protocol Algorithms Demo")
    print("=" * 50)
    
    # Find parameters
    random.seed(42)
    q = nextprime(2**32)
    while not isprime(2 * q + 1):
        q = nextprime(q)
    p = 2 * q + 1
    g = find_g(p, q)
    params = GroupParams(p=p, q=q, g=g)
    
    print(f"Group: (ℤ/{p}ℤ)* subgroup of order {q}")
    print(f"Generator: {g}")
    
    # Key generation
    kp = schnorr_keygen(params)
    print(f"\nSecret key: {kp.secret}")
    print(f"Public key: {kp.public}")
    
    # Interactive proof
    a, r = schnorr_commit(params)
    c = secrets.randbelow(params.q)
    z = schnorr_respond(params, kp.secret, r, c)
    t = Transcript(commitment=a, challenge=c, response=z)
    print(f"\nInteractive proof verified: {schnorr_verify(params, kp.public, t)}")
    
    # Simulator
    t_sim = schnorr_simulate(params, kp.public)
    print(f"Simulated proof verified: {schnorr_verify(params, kp.public, t_sim)}")
    
    # Fiat-Shamir
    y, proof = fiat_shamir_prove(params, kp.secret)
    print(f"Fiat-Shamir proof verified: {fiat_shamir_verify(params, y, proof)}")
    
    # Special soundness
    r_fixed = secrets.randbelow(params.q)
    c1, c2 = 42, 137
    a_fixed = pow(params.g, r_fixed, params.p)
    z1 = schnorr_respond(params, kp.secret, r_fixed, c1)
    z2 = schnorr_respond(params, kp.secret, r_fixed, c2)
    t1 = Transcript(a_fixed, c1, z1)
    t2 = Transcript(a_fixed, c2, z2)
    x_ext = schnorr_extract(params, t1, t2)
    print(f"\nExtracted witness matches: {x_ext == kp.secret}")


def find_g(p, q):
    for h in range(2, p):
        g = pow(h, (p - 1) // q, p)
        if g != 1:
            return g
