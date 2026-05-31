"""
Algorithms for Isogeny-Based Cryptography: CSIDH and CSI-FiSh

Type-hinted implementations of the core algorithms formalized in Lean 4.
These operate over abstract finite cyclic groups (modeled as Z/nZ).
"""

from typing import Tuple, List, Optional
import hashlib
import secrets


class CyclicGroupAction:
    """
    Models the class group action on supersingular curves.

    In the concrete CSIDH setting:
      - G = Cl(O) ≅ Z/nZ (class group, abelian)
      - X = {j-invariants of supersingular curves over F_p}
      - act(g, x) = g · x (isogeny composition)

    For simulation, we use G = X = Z/nZ with act(g, x) = g + x mod n.
    """

    def __init__(self, n: int) -> None:
        """Initialize with group/set order n."""
        self.n = n

    def act(self, g: int, x: int) -> int:
        """Group action: g · x = g + x mod n."""
        return (g + x) % self.n

    def identity(self) -> int:
        """Identity element."""
        return 0

    def inverse(self, g: int) -> int:
        """Group inverse: -g mod n."""
        return (-g) % self.n

    def multiply(self, g: int, h: int) -> int:
        """Group multiplication: g * h = g + h mod n."""
        return (g + h) % self.n

    def connector(self, x: int, y: int) -> int:
        """
        Compute the unique group element mapping x to y.
        This is the GAIP solution: connector(x, y) = y - x mod n.
        In a real cryptographic setting, this is the hard problem.
        """
        return (y - x) % self.n


class CSIDHKeyExchange:
    """
    CSIDH Key Exchange Protocol.

    Correctness: Alice and Bob compute the same shared secret
    because the class group is abelian (commutative).
    """

    def __init__(self, group: CyclicGroupAction, base_point: int = 0) -> None:
        self.group = group
        self.base_point = base_point

    def keygen(self) -> Tuple[int, int]:
        """Generate (secret_key, public_key) pair."""
        sk = secrets.randbelow(self.group.n)
        pk = self.group.act(sk, self.base_point)
        return sk, pk

    def shared_secret(self, my_secret: int, their_public: int) -> int:
        """Compute shared secret from my secret and their public key."""
        return self.group.act(my_secret, their_public)

    def verify_correctness(self, alice_sk: int, bob_sk: int) -> bool:
        """
        Verify that Alice and Bob compute the same shared secret.
        This is the machine-verified theorem shared_secret_agreement.
        """
        alice_pk = self.group.act(alice_sk, self.base_point)
        bob_pk = self.group.act(bob_sk, self.base_point)

        alice_shared = self.group.act(alice_sk, bob_pk)
        bob_shared = self.group.act(bob_sk, alice_pk)

        return alice_shared == bob_shared


class CSIFiShSignature:
    """
    CSI-FiSh Digital Signature Scheme.

    Uses the Fiat-Shamir transform on the CSI-FiSh identification protocol.
    Security relies on the hardness of GAIP (Group Action Inverse Problem).
    """

    def __init__(
        self,
        group: CyclicGroupAction,
        base_point: int = 0,
        num_rounds: int = 128,
    ) -> None:
        self.group = group
        self.base_point = base_point
        self.num_rounds = num_rounds

    def keygen(self) -> Tuple[int, int]:
        """Generate signing key pair."""
        sk = secrets.randbelow(self.group.n)
        pk = self.group.act(sk, self.base_point)
        return sk, pk

    def _hash_to_challenges(
        self, commitments: List[int], message: bytes
    ) -> List[int]:
        """Hash commitments and message to challenge bits."""
        data = b""
        for c in commitments:
            data += c.to_bytes(32, "big")
        data += message

        h = hashlib.sha256(data).digest()
        # Extract num_rounds bits
        challenges = []
        for i in range(self.num_rounds):
            byte_idx = i // 8
            bit_idx = i % 8
            if byte_idx < len(h):
                challenges.append((h[byte_idx] >> bit_idx) & 1)
            else:
                # Extend hash if needed
                h = hashlib.sha256(h).digest()
                byte_idx = (i % 256) // 8
                challenges.append((h[byte_idx] >> bit_idx) & 1)
        return challenges

    def sign(self, sk: int, message: bytes) -> Tuple[List[int], List[int]]:
        """
        Sign a message using the Fiat-Shamir transform.

        Returns (challenges, responses).
        """
        pk = self.group.act(sk, self.base_point)

        # Step 1: Generate random commitments
        randomness = [secrets.randbelow(self.group.n) for _ in range(self.num_rounds)]
        commitments = [
            self.group.act(r, self.base_point) for r in randomness
        ]

        # Step 2: Compute challenges via hash
        challenges = self._hash_to_challenges(commitments, message)

        # Step 3: Compute responses
        responses = []
        for i in range(self.num_rounds):
            if challenges[i] == 0:
                responses.append(randomness[i])
            else:
                # z = r * s^{-1} = r - s mod n
                z = self.group.multiply(
                    randomness[i], self.group.inverse(sk)
                )
                responses.append(z)

        return challenges, responses

    def verify(
        self, pk: int, message: bytes, challenges: List[int], responses: List[int]
    ) -> bool:
        """
        Verify a signature.

        For challenge 0: check z · x₀ = R (commitment)
        For challenge 1: check z · pk = R (commitment)
        """
        # Reconstruct commitments from responses and challenges
        commitments = []
        for i in range(self.num_rounds):
            if challenges[i] == 0:
                commitments.append(self.group.act(responses[i], self.base_point))
            else:
                commitments.append(self.group.act(responses[i], pk))

        # Verify hash matches
        expected_challenges = self._hash_to_challenges(commitments, message)
        return challenges == expected_challenges

    def extract_secret(
        self,
        z0: int,
        z1: int,
    ) -> int:
        """
        Special soundness extraction.

        Given two responses z0 (for challenge 0) and z1 (for challenge 1)
        on the same commitment, extract the secret key: sk = z0 * z1^{-1}.

        This is the machine-verified theorem csifish_special_soundness.
        """
        return self.group.multiply(z0, self.group.inverse(z1))


class IsogenyCayleyGraph:
    """
    Cayley graph of the group action with a generating set.

    In CSIDH, generators correspond to small prime ideals.
    """

    def __init__(
        self,
        group: CyclicGroupAction,
        generators: List[int],
    ) -> None:
        self.group = group
        self.generators = generators
        # Ensure generators are closed under inverses
        gen_set = set(generators)
        for g in generators:
            gen_set.add(group.inverse(g))
        self.generators = list(gen_set)

    def neighbors(self, x: int) -> List[int]:
        """Get all neighbors of vertex x."""
        return [self.group.act(g, x) for g in self.generators]

    def bfs_distance(self, start: int, end: int) -> int:
        """Compute shortest path distance using BFS."""
        if start == end:
            return 0

        visited = {start}
        queue = [(start, 0)]
        head = 0

        while head < len(queue):
            current, dist = queue[head]
            head += 1

            for neighbor in self.neighbors(current):
                if neighbor == end:
                    return dist + 1
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append((neighbor, dist + 1))

        return -1  # unreachable

    def diameter(self) -> int:
        """Compute the diameter of the graph."""
        max_dist = 0
        for x in range(self.group.n):
            for y in range(x + 1, self.group.n):
                d = self.bfs_distance(x, y)
                max_dist = max(max_dist, d)
        return max_dist

    def test_diameter_conjecture(self) -> Tuple[bool, int, int]:
        """
        Test the Cayley diameter conjecture: for Z/nZ with generators {1, -1},
        the diameter should be ⌊n/2⌋.

        Returns (conjecture_holds, actual_diameter, expected_diameter).
        """
        actual = self.diameter()
        expected = self.group.n // 2
        return actual == expected, actual, expected


def random_walk_distribution(
    group: CyclicGroupAction,
    generators: List[int],
    steps: int,
    num_samples: int = 10000,
) -> dict:
    """
    Estimate the distribution of a random walk on the Cayley graph.

    Returns a dictionary mapping elements to their estimated probabilities.
    """
    counts: dict = {x: 0 for x in range(group.n)}

    for _ in range(num_samples):
        x = 0  # start at identity
        for _ in range(steps):
            g = secrets.choice(generators)
            x = group.act(g, x)
        counts[x] += 1

    return {k: v / num_samples for k, v in counts.items()}


def total_variation_distance(dist: dict, n: int) -> float:
    """Compute total variation distance from uniform distribution."""
    uniform = 1.0 / n
    return 0.5 * sum(abs(dist.get(x, 0) - uniform) for x in range(n))
