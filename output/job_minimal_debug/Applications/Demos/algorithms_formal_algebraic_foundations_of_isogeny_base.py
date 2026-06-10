"""
Isogeny-Based Cryptography: Core Algorithms

Type-hinted implementations of the algebraic primitives underlying
CSIDH, CSI-FiSh, and related protocols.
"""

from typing import TypeVar, Generic, List, Tuple, Optional, Callable
from dataclasses import dataclass
from abc import ABC, abstractmethod
import random


# ─── Type Variables ───────────────────────────────────────────────
G = TypeVar('G')  # Group element type
X = TypeVar('X')  # Set element type


# ─── Abstract Group Action ────────────────────────────────────────

class GroupAction(ABC, Generic[G, X]):
    """Abstract free transitive group action (torsor)."""

    @abstractmethod
    def act(self, g: G, x: X) -> X:
        """Apply group element g to point x."""
        ...

    @abstractmethod
    def identity(self) -> G:
        """Return the group identity element."""
        ...

    @abstractmethod
    def inverse(self, g: G) -> G:
        """Return the group inverse of g."""
        ...

    @abstractmethod
    def multiply(self, g: G, h: G) -> G:
        """Return the group product g * h."""
        ...

    @abstractmethod
    def connector(self, x: X, y: X) -> G:
        """Compute the unique g such that g · x = y (GAIP oracle)."""
        ...


# ─── Concrete: Cyclic Group Action ───────────────────────────────

class CyclicGroupAction(GroupAction[int, int]):
    """ℤ/nℤ acting on itself by addition. Concrete model for testing."""

    def __init__(self, n: int):
        self.n = n

    def act(self, g: int, x: int) -> int:
        return (g + x) % self.n

    def identity(self) -> int:
        return 0

    def inverse(self, g: int) -> int:
        return (-g) % self.n

    def multiply(self, g: int, h: int) -> int:
        return (g + h) % self.n

    def connector(self, x: int, y: int) -> int:
        return (y - x) % self.n


# ─── CSIDH Key Exchange ──────────────────────────────────────────

@dataclass
class CSIDHKeyPair(Generic[G, X]):
    """A CSIDH key pair: secret key in G, public key in X."""
    secret: G
    public: X


@dataclass
class CSIDHParams(Generic[G, X]):
    """CSIDH public parameters."""
    action: GroupAction[G, X]
    base_point: X


def csidh_keygen(params: CSIDHParams[G, X], secret: G) -> CSIDHKeyPair[G, X]:
    """Generate a CSIDH key pair.

    Algorithm:
        1. Choose secret key s ∈ G
        2. Compute public key pk = s · x₀
        3. Return (s, pk)
    """
    pk = params.action.act(secret, params.base_point)
    return CSIDHKeyPair(secret=secret, public=pk)


def csidh_shared_secret(
    params: CSIDHParams[G, X],
    my_secret: G,
    their_public: X
) -> X:
    """Compute the CSIDH shared secret.

    Algorithm:
        shared = my_secret · their_public

    Correctness: Alice computes a · (b · x₀) = Bob computes b · (a · x₀)
    because the group is abelian.
    """
    return params.action.act(my_secret, their_public)


# ─── CSI-FiSh Identification / Signature ─────────────────────────

@dataclass
class CSIFiShTranscript(Generic[G, X]):
    """A CSI-FiSh identification transcript."""
    commitment: X        # R = r · x₀
    challenge: bool      # c ∈ {0, 1}
    response: G          # z

    def verify(self, params: CSIDHParams[G, X], pk: X) -> bool:
        """Verify the transcript.

        If c = 0: check z · x₀ = R
        If c = 1: check z · pk = R
        """
        if self.challenge:
            return params.action.act(self.response, pk) == self.commitment
        else:
            return params.action.act(self.response, params.base_point) == self.commitment


def csifish_prove(
    params: CSIDHParams[G, X],
    secret: G,
    challenge: bool,
    randomness: G
) -> CSIFiShTranscript[G, X]:
    """Honest CSI-FiSh prover.

    Algorithm:
        1. Commit: R = r · x₀
        2. If c = 0: respond z = r
        3. If c = 1: respond z = r · s⁻¹
    """
    R = params.action.act(randomness, params.base_point)
    if challenge:
        z = params.action.multiply(randomness, params.action.inverse(secret))
    else:
        z = randomness
    return CSIFiShTranscript(commitment=R, challenge=challenge, response=z)


def csifish_extract(
    params: CSIDHParams[G, X],
    t0: CSIFiShTranscript[G, X],
    t1: CSIFiShTranscript[G, X]
) -> G:
    """Extract secret from two transcripts with different challenges.

    Given:
        t0: challenge=0, z₀ · x₀ = R
        t1: challenge=1, z₁ · pk = R

    Extract: s = z₀ · z₁⁻¹

    This is the special soundness extractor: two accepting transcripts
    on the same commitment with different challenges yield the secret.
    """
    z0_inv_z1 = params.action.multiply(
        t0.response,
        params.action.inverse(t1.response)
    )
    return z0_inv_z1


# ─── Vectorization Problem ───────────────────────────────────────

def solve_vectorization(
    params: CSIDHParams[G, X],
    x1: X,
    x2: X
) -> X:
    """Solve the vectorization problem using a GAIP oracle.

    Given x₀, x₁ = a · x₀, x₂ = b · x₀, compute (a · b) · x₀.

    Algorithm:
        1. a ← connector(x₀, x₁)    [GAIP oracle call]
        2. b ← connector(x₀, x₂)    [GAIP oracle call]
        3. Return (a · b) · x₀
    """
    a = params.action.connector(params.base_point, x1)
    b = params.action.connector(params.base_point, x2)
    ab = params.action.multiply(a, b)
    return params.action.act(ab, params.base_point)


# ─── Twist Operations ────────────────────────────────────────────

class TwistedGroupAction(Generic[G, X]):
    """Group action with a twist endomorphism τ satisfying τ(g·x) = g⁻¹·τ(x)."""

    def __init__(self, action: GroupAction[G, X], twist: Callable[[X], X]):
        self.action = action
        self.twist = twist

    def connector_under_twist(self, x: X, y: X) -> G:
        """Compute connector(τ(x), τ(y)) = connector(x, y)⁻¹."""
        conn = self.action.connector(x, y)
        return self.action.inverse(conn)


# ─── Commitment Scheme ───────────────────────────────────────────

@dataclass
class GACommitment(Generic[G, X]):
    """Group-action commitment: (r·x₀, (r·m)·x₀)."""
    com1: X  # r · x₀
    com2: X  # (r · m) · x₀


def ga_commit(
    params: CSIDHParams[G, X],
    message: G,
    randomness: G
) -> GACommitment[G, X]:
    """Commit to a message m using randomness r.

    Algorithm:
        c₁ = r · x₀
        c₂ = (r · m) · x₀
    """
    rm = params.action.multiply(randomness, message)
    return GACommitment(
        com1=params.action.act(randomness, params.base_point),
        com2=params.action.act(rm, params.base_point)
    )


def ga_extract_message(
    params: CSIDHParams[G, X],
    commitment: GACommitment[G, X]
) -> G:
    """Extract the committed message using the GAIP oracle.

    Algorithm: m = connector(c₁, c₂)
    """
    return params.action.connector(commitment.com1, commitment.com2)


# ─── Cayley Graph Diameter ───────────────────────────────────────

def cayley_diameter_bfs(n: int) -> int:
    """Compute the Cayley graph diameter for ℤ/nℤ with generators {1, -1}.

    Uses BFS from 0 to find the maximum distance to any vertex.
    """
    if n <= 1:
        return 0

    visited = {0: 0}
    queue = [0]
    max_dist = 0

    while queue:
        current = queue.pop(0)
        for delta in [1, n - 1]:
            neighbor = (current + delta) % n
            if neighbor not in visited:
                visited[neighbor] = visited[current] + 1
                max_dist = max(max_dist, visited[neighbor])
                queue.append(neighbor)

    return max_dist


def verify_cayley_diameter_conjecture(n_values: List[int]) -> List[Tuple[int, int, int, bool]]:
    """Verify the Cayley diameter conjecture for given values of n.

    Returns list of (n, computed_diameter, n//2, matches).
    """
    results = []
    for n in n_values:
        diameter = cayley_diameter_bfs(n)
        expected = n // 2
        results.append((n, diameter, expected, diameter == expected))
    return results


# ─── Security Parameter Computation ──────────────────────────────

def csidh_keyspace_size(num_primes: int, bound: int) -> int:
    """Compute the CSIDH key space size: (2B + 1)^n."""
    return (2 * bound + 1) ** num_primes


def challenge_space_size(num_rounds: int) -> int:
    """Compute the CSI-FiSh challenge space size: 2^n."""
    return 2 ** num_rounds


def security_bits(num_rounds: int) -> int:
    """Approximate security bits for CSI-FiSh with n rounds."""
    return num_rounds  # soundness error = 2^{-n}
