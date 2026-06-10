#!/usr/bin/env python3
"""
Algorithms for CSIDH-Style Group Action Cryptography

Type-hinted implementations of the core algorithms formalized in Lean 4.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable
import math


# ============================================================================
# Core Types
# ============================================================================

@dataclass
class GroupAction:
    """Abstract group action on a finite set.
    
    Models the CSIDH ideal class group action. Elements are integers mod n.
    """
    n: int  # Group/set order
    
    def act(self, g: int, x: int) -> int:
        """Apply group element g to set element x."""
        return (g + x) % self.n
    
    def conn(self, x: int, y: int) -> int:
        """Compute the unique connector: g such that g·x = y."""
        return (y - x) % self.n
    
    def identity(self) -> int:
        return 0
    
    def inverse(self, g: int) -> int:
        return (-g) % self.n
    
    def multiply(self, g: int, h: int) -> int:
        return (g + h) % self.n


# ============================================================================
# Algorithm 1: Torsor Trivialization
# ============================================================================

def trivialize(ga: GroupAction, basepoint: int, y: int) -> int:
    """
    Trivialize: given basepoint x₀, map y ↦ conn(x₀, y).
    
    This establishes a bijection X ≃ G that intertwines the group action
    with left multiplication. Time: O(1) for cyclic groups.
    
    Pseudocode:
        function TRIVIALIZE(x₀, y):
            return CONN(x₀, y)
    """
    return ga.conn(basepoint, y)


def untrivialize(ga: GroupAction, basepoint: int, g: int) -> int:
    """
    Inverse trivialization: g ↦ g · x₀.
    
    Pseudocode:
        function UNTRIVIALIZE(x₀, g):
            return ACT(g, x₀)
    """
    return ga.act(g, basepoint)


# ============================================================================
# Algorithm 2: CSIDH Key Exchange
# ============================================================================

@dataclass
class CSIDHKeyPair:
    """A CSIDH key pair."""
    secret: int
    public: int


def csidh_keygen(ga: GroupAction, basepoint: int) -> CSIDHKeyPair:
    """
    Generate a CSIDH key pair.
    
    Pseudocode:
        function KEYGEN(x₀):
            s ← random element of G
            pk ← ACT(s, x₀)
            return (s, pk)
    """
    import random
    s = random.randint(0, ga.n - 1)
    pk = ga.act(s, basepoint)
    return CSIDHKeyPair(secret=s, public=pk)


def csidh_shared_secret(ga: GroupAction, my_secret: int, their_public: int) -> int:
    """
    Compute the CSIDH shared secret.
    
    Pseudocode:
        function SHARED_SECRET(s, pk_other):
            return ACT(s, pk_other)
    """
    return ga.act(my_secret, their_public)


# ============================================================================
# Algorithm 3: Multi-Party CSIDH
# ============================================================================

def multiparty_secret(ga: GroupAction, basepoint: int, secrets: List[int]) -> int:
    """
    Compute n-party shared secret: ACT(∏ secrets, x₀).
    
    By commutativity, the order of secrets doesn't matter.
    
    Pseudocode:
        function MULTIPARTY_SECRET(x₀, [s₁, ..., sₙ]):
            product ← s₁ · s₂ · ... · sₙ
            return ACT(product, x₀)
    """
    product = sum(secrets) % ga.n
    return ga.act(product, basepoint)


def multiparty_round(ga: GroupAction, intermediate: int,
                     party_secrets: List[int], excluded_index: int) -> int:
    """
    One round of multi-party CSIDH: compute the intermediate value
    with one party's secret excluded (for that party to apply last).
    
    Pseudocode:
        function ROUND(intermediate, secrets, exclude):
            for i ≠ exclude:
                intermediate ← ACT(secrets[i], intermediate)
            return intermediate
    """
    result = intermediate
    for i, s in enumerate(party_secrets):
        if i != excluded_index:
            result = ga.act(s, result)
    return result


# ============================================================================
# Algorithm 4: Sigma Protocol (CSI-FiSh)
# ============================================================================

@dataclass
class SigmaTranscript:
    """A sigma protocol transcript."""
    commitment: int
    challenge: bool
    response: int


def sigma_prove(ga: GroupAction, basepoint: int, secret: int,
                challenge: bool) -> SigmaTranscript:
    """
    Generate a sigma protocol proof.
    
    Pseudocode:
        function PROVE(x₀, s, challenge):
            r ← random element of G
            commitment ← ACT(r, x₀)
            if challenge = 0:
                response ← r
            else:
                response ← r · s⁻¹
            return (commitment, challenge, response)
    """
    import random
    r = random.randint(0, ga.n - 1)
    commitment = ga.act(r, basepoint)
    if not challenge:
        response = r
    else:
        response = ga.multiply(r, ga.inverse(secret))
    return SigmaTranscript(commitment=commitment, challenge=challenge,
                          response=response)


def sigma_verify(ga: GroupAction, basepoint: int, public_key: int,
                 transcript: SigmaTranscript) -> bool:
    """
    Verify a sigma protocol transcript.
    
    Pseudocode:
        function VERIFY(x₀, pk, (R, c, z)):
            if c = 0: return ACT(z, x₀) = R
            else: return ACT(z, pk) = R
    """
    if not transcript.challenge:
        return ga.act(transcript.response, basepoint) == transcript.commitment
    else:
        return ga.act(transcript.response, public_key) == transcript.commitment


def sigma_extract(ga: GroupAction, t0: SigmaTranscript,
                  t1: SigmaTranscript) -> int:
    """
    Extract the secret from two accepting transcripts with different challenges.
    
    Pseudocode:
        function EXTRACT(t₀, t₁):
            assert t₀.commitment = t₁.commitment
            assert t₀.challenge ≠ t₁.challenge
            return t₀.response · t₁.response⁻¹
    """
    assert t0.commitment == t1.commitment
    assert t0.challenge != t1.challenge
    return ga.multiply(t0.response, ga.inverse(t1.response))


# ============================================================================
# Algorithm 5: Group Action Hash
# ============================================================================

def pair_hash(ga: GroupAction, x0: int, x1: int, g: int) -> Tuple[int, int]:
    """
    Pair hash function: H(g) = (g·x₀, g·x₁).
    Collision-resistant under GAIP hardness.
    
    Pseudocode:
        function PAIR_HASH(x₀, x₁, g):
            return (ACT(g, x₀), ACT(g, x₁))
    """
    return (ga.act(g, x0), ga.act(g, x1))


# ============================================================================
# Algorithm 6: Cayley Graph BFS Diameter
# ============================================================================

def cayley_diameter(n: int, generators: List[int]) -> int:
    """
    Compute the diameter of the Cayley graph Cay(Z/nZ, generators) via BFS.
    
    Pseudocode:
        function CAYLEY_DIAMETER(n, S):
            dist ← array of -1, size n
            dist[0] ← 0
            queue ← [0]
            max_dist ← 0
            while queue not empty:
                v ← dequeue
                for s in S:
                    w ← (v + s) mod n
                    if dist[w] = -1:
                        dist[w] ← dist[v] + 1
                        max_dist ← max(max_dist, dist[w])
                        enqueue w
            return max_dist
    """
    dist = [-1] * n
    dist[0] = 0
    queue = [0]
    max_dist = 0
    
    while queue:
        v = queue.pop(0)
        for s in generators:
            w = (v + s) % n
            if dist[w] == -1:
                dist[w] = dist[v] + 1
                max_dist = max(max_dist, dist[w])
                queue.append(w)
    
    return max_dist


def spectral_gap(n: int) -> float:
    """
    Compute the spectral gap of Cay(Z/nZ, {1, -1}).
    
    For the circulant graph, eigenvalues are 2cos(2πk/n) for k = 0, ..., n-1.
    The spectral gap is λ₁ - λ₂ = 2 - 2cos(2π/n) = 2(1 - cos(2π/n)).
    """
    return 2 * (1 - math.cos(2 * math.pi / n))


# ============================================================================
# Algorithm 7: Security Amplification
# ============================================================================

def parallel_advantage(epsilon: float, n: int) -> float:
    """
    Compute the advantage after n parallel repetitions.
    
    Pseudocode:
        function PARALLEL_ADVANTAGE(ε, n):
            return εⁿ
    """
    return epsilon ** n


def required_repetitions(epsilon: float, target: float) -> int:
    """
    Compute minimum repetitions to achieve target advantage.
    
    Pseudocode:
        function REQUIRED_REPS(ε, target):
            return ⌈log(target) / log(ε)⌉
    """
    if epsilon <= 0 or epsilon >= 1 or target <= 0:
        return -1
    return math.ceil(math.log(target) / math.log(epsilon))


if __name__ == "__main__":
    # Quick demonstration
    ga = GroupAction(n=97)
    
    # Key exchange
    alice = csidh_keygen(ga, 0)
    bob = csidh_keygen(ga, 0)
    
    alice_shared = csidh_shared_secret(ga, alice.secret, bob.public)
    bob_shared = csidh_shared_secret(ga, bob.secret, alice.public)
    
    print(f"Alice secret: {alice.secret}, public: {alice.public}")
    print(f"Bob secret: {bob.secret}, public: {bob.public}")
    print(f"Alice shared: {alice_shared}")
    print(f"Bob shared: {bob_shared}")
    print(f"Agreement: {'✓' if alice_shared == bob_shared else '✗'}")
    
    # Cayley diameter
    for n in [5, 7, 11, 13, 17]:
        d = cayley_diameter(n, [1, n-1])
        print(f"Cay(Z/{n}Z, {{1,-1}}): diameter = {d}, expected = {n//2}")
